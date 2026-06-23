--ルイ・キューピット
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合发动。这张卡的等级上升或下降那只作为同调素材的调整的等级数值。
-- ②：这张卡的攻击力上升这张卡的等级×400。
-- ③：同调召唤的这张卡作为同调素材送去墓地的场合发动。给与对方这张卡为同调素材的同调怪兽的等级×100伤害，可以从卡组把1只8星以下而守备力600的怪兽加入手卡。
function c21915012.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求必须有1只调整作为同调素材，其余素材为调整以外的怪兽
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
	-- ②：这张卡的攻击力上升这张卡的等级×400。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c21915012.valcheck)
	e0:SetLabelObject(e1)
	c:RegisterEffect(e0)
	-- ③：同调召唤的这张卡作为同调素材送去墓地的场合发动。给与对方这张卡为同调素材的同调怪兽的等级×100伤害，可以从卡组把1只8星以下而守备力600的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c21915012.atkval)
	c:RegisterEffect(e2)
	-- 为卡片注册一个用于检查同调素材的永续效果，用于确定等级变化的数值
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
	-- 为成为同调素材的卡片与其对应的素材触发效果建立关联，确保在效果处理期间能够正确识别并获取本次召唤所使用的原因怪兽
	aux.CreateMaterialReasonCardRelation(c,e3)
end
-- 过滤函数，用于判断卡片是否为调整类型
function c21915012.matfilter(c)
	return c:IsType(TYPE_TUNER)
end
-- 检查同调召唤时使用的素材，确定等级变化的数值
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
-- 判断效果是否在同调召唤成功时触发
function c21915012.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 根据选择的结果，调整卡片的等级
function c21915012.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local ct=e:GetLabel()
	if ct==0 then return end
	local sel=nil
	if c:IsLevel(1) then
		-- 当卡片等级为1时，选择是否提升等级
		sel=Duel.SelectOption(tp,aux.Stringid(21915012,1))  --"等级上升"
	else
		-- 当卡片等级大于1时，选择提升或降低等级
		sel=Duel.SelectOption(tp,aux.Stringid(21915012,1),aux.Stringid(21915012,2))  --"等级上升/等级下降"
	end
	if sel==1 then
		ct=ct*-1
	end
	-- 设置卡片等级变化的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(ct)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 计算卡片攻击力的函数，攻击力等于等级乘以400
function c21915012.atkval(e,c)
	return c:GetLevel()*400
end
-- 判断效果是否在作为同调素材送去墓地时触发
function c21915012.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤函数，用于筛选卡组中8星以下且守备力为600的怪兽
function c21915012.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(8) and c:IsDefense(600) and c:IsAbleToHand()
end
-- 设置效果的目标和操作信息，包括造成伤害和检索卡组
function c21915012.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	local lv=rc:GetLevel()
	if chk==0 then return true end
	if rc:IsRelateToEffect(e) and rc:IsFaceup() then
		-- 设置当前处理的连锁的对象为作为同调素材的怪兽
		Duel.SetTargetCard(rc)
		-- 设置当前处理的连锁的操作信息，包括造成伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,lv*100)
	end
end
-- 处理效果的执行逻辑，包括造成伤害和检索卡组
function c21915012.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的处理对象，即作为同调素材的怪兽
	local rc=Duel.GetFirstTarget()
	if not rc or not rc:IsRelateToChain() or rc:IsFacedown() then return end
	local lv=rc:GetLevel()
	-- 造成对方受到等级×100的伤害，并检查卡组中是否存在符合条件的怪兽
	if Duel.Damage(1-tp,lv*100,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(c21915012.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否从卡组把怪兽加入手卡
		and Duel.SelectYesNo(tp,aux.Stringid(21915012,3)) then  --"是否从卡组把怪兽加入手卡？"
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从卡组中选择符合条件的怪兽加入手牌
			local g=Duel.SelectMatchingCard(tp,c21915012.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方查看加入手牌的怪兽
			Duel.ConfirmCards(1-tp,g)
	end
end
