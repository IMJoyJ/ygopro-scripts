--ルイ・キューピット
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合发动。这张卡的等级上升或下降那只作为同调素材的调整的等级数值。
-- ②：这张卡的攻击力上升这张卡的等级×400。
-- ③：同调召唤的这张卡作为同调素材送去墓地的场合发动。给与对方这张卡为同调素材的同调怪兽的等级×100伤害，可以从卡组把1只8星以下而守备力600的怪兽加入手卡。
function c21915012.initial_effect(c)
	-- 为这张卡添加同调召唤手续：使用1只调整怪兽＋1只以上调整以外的怪兽作为素材进行同调召唤。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合发动。这张卡的等级上升或下降那只作为同调素材的调整的等级数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21915012,4))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c21915012.lvcon)
	e1:SetOperation(c21915012.lvop)
	c:RegisterEffect(e1)
	-- ①：这张卡同调召唤的场合发动。这张卡的等级上升或下降那只作为同调素材的调整的等级数值。（此处通过素材检查效果预先记录素材调整的等级，供①效果发动时使用）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c21915012.valcheck)
	e0:SetLabelObject(e1)
	c:RegisterEffect(e0)
	-- ②：这张卡的攻击力上升这张卡的等级×400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c21915012.atkval)
	c:RegisterEffect(e2)
	-- ③：同调召唤的这张卡作为同调素材送去墓地的场合发动。给与对方这张卡为同调素材的同调怪兽的等级×100伤害，可以从卡组把1只8星以下而守备力600的怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21915012,0))
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,21915012)
	e3:SetCondition(c21915012.thcon)
	e3:SetTarget(c21915012.thtg)
	e3:SetOperation(c21915012.thop)
	c:RegisterEffect(e3)
	-- 为这张卡与③效果e3建立素材关联登记，确保这张卡作为同调素材被送去墓地时能够正确触发③效果。
	aux.CreateMaterialReasonCardRelation(c,e3)
end
-- 素材过滤函数：判断怪兽是否为调整怪兽（用于同调素材的选择）。
function c21915012.matfilter(c)
	return c:IsType(TYPE_TUNER)
end
-- 素材检查函数：在同调召唤成功时检查实际使用的素材，取出其中作为调整的怪兽，计算其等级（考虑星级变化等特殊情况）并存入①效果e1的标签中，作为①效果改变等级的数值；若没有调整素材则存入0。
function c21915012.valcheck(e,c)
	local g=c:GetMaterial()
	local mg=g:Filter(Card.IsTuner,nil,c)
	local tc=mg:GetFirst()
	if not tc then
		e:GetLabelObject():SetLabel(0)
		return
	end
	if #mg>1 then
		local tg=g-(g:Filter(Card.IsNotTuner,nil,c))
		if #tg>0 then
			tc=tg:GetFirst()
		end
	end
	local lv=tc:GetSynchroLevel(c)
	local lv2=lv>>16
	lv=lv&0xffff
	if lv2>0 and not g:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),#g,#g,c) then
		lv=lv2
	end
	if tc:IsHasEffect(89818984) and not g:CheckWithSumEqual(Card.GetSynchroLevel,c:GetLevel(),#g,#g,c) then
		lv=2
	end
	e:GetLabelObject():SetLabel(lv)
end
-- ①效果的发动条件：这张卡是以同调召唤方式特殊召唤成功的场合。
function c21915012.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ①效果的处理：若记录到的素材调整等级不为0，则根据这张卡当前等级让玩家选择等级上升还是下降（当前等级为1时只能上升），然后将该等级变化值应用给这张卡。
function c21915012.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local ct=e:GetLabel()
	if ct==0 then return end
	local sel=nil
	if c:IsLevel(1) then
		-- 当这张卡当前等级为1时，不能选择下降，因此只提供“等级上升”选项。
		sel=Duel.SelectOption(tp,aux.Stringid(21915012,1))  --"等级上升"
	else
		-- 当这张卡当前等级大于1时，提供“等级上升/等级下降”两个选项供玩家选择。
		sel=Duel.SelectOption(tp,aux.Stringid(21915012,1),aux.Stringid(21915012,2))  --"等级上升/等级下降"
	end
	if sel==1 then
		ct=ct*-1
	end
	-- 这张卡的等级上升或下降那只作为同调素材的调整的等级数值。（将等级变化效果赋予这张卡）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(ct)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 攻击力提升数值函数：返回这张卡当前等级×400，作为②效果的攻击力上升值。
function c21915012.atkval(e,c)
	return c:GetLevel()*400
end
-- ③效果的发动条件：这张卡是通过同调召唤出场的这张卡，并且在作为同调素材被送去墓地的场合（位于墓地且原因为同调召唤）。
function c21915012.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 检索过滤函数：从卡组选择1只8星以下、守备力600、并且可以加入手卡的怪兽。
function c21915012.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(8) and c:IsDefense(600) and c:IsAbleToHand()
end
-- ③效果的发动时目标处理：取得这张卡作为素材的那只同调怪兽（ReasonCard），记录其等级；在效果处理前设置给对方造成等级×100伤害的操作信息。
function c21915012.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	local lv=rc:GetLevel()
	if chk==0 then return true end
	if rc:IsRelateToEffect(e) and rc:IsFaceup() then
		-- 将作为素材的同调怪兽设置为当前效果的对象，以便后续处理时获取其等级及关联状态。
		Duel.SetTargetCard(rc)
		-- 设置本次伤害的操作信息：对对方造成那只同调怪兽等级×100的伤害，以便相关卡牌（如星尘龙等）能正确响应。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,lv*100)
	end
end
-- ③效果的处理：首先给与对方那只作为同调素材的同调怪兽等级×100伤害；若伤害实际造成且卡组中存在符合条件的怪兽，则询问玩家是否将1只8星以下、守备力600的怪兽加入手卡，选择后加入并给对方确认。
function c21915012.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理阶段的对象卡，即那只作为同调素材的同调怪兽。
	local rc=Duel.GetFirstTarget()
	if not rc or not rc:IsRelateToChain() or rc:IsFacedown() then return end
	local lv=rc:GetLevel()
	-- 给与对方等级×100伤害，同时检查卡组中是否存在1只符合条件的检索目标；只有伤害成功且存在可检索的怪兽时，才继续后续检索。
	if Duel.Damage(1-tp,lv*100,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(c21915012.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 向玩家询问是否从卡组把符合条件的怪兽加入手卡。
		and Duel.SelectYesNo(tp,aux.Stringid(21915012,3)) then  --"是否从卡组把怪兽加入手卡？"
			-- 弹出从卡组选择要加入手卡的卡的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从卡组选择1只符合条件的怪兽（8星以下、守备力600）。
			local g=Duel.SelectMatchingCard(tp,c21915012.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选择的怪兽加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手卡的怪兽展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
	end
end
