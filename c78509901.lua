--方界獣ブレード・ガルーディア
-- 效果：
-- 这张卡不能通常召唤。把自己场上2只「方界」怪兽送去墓地的场合可以特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力上升2000。
-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ③：这张卡战斗破坏怪兽时，以自己墓地最多3只「方界胤 毗贾姆」为对象才能发动。这张卡送去墓地，作为对象的怪兽特殊召唤。那之后，可以从卡组把1只「方界超兽 破坏之乾闼尔」加入手卡。
function c78509901.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上2只「方界」怪兽送去墓地的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c78509901.spcon)
	e2:SetTarget(c78509901.sptg)
	e2:SetOperation(c78509901.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：这张卡战斗破坏怪兽时，以自己墓地最多3只「方界胤 毗贾姆」为对象才能发动。这张卡送去墓地，作为对象的怪兽特殊召唤。那之后，可以从卡组把1只「方界超兽 破坏之乾闼尔」加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置发动条件为这张卡战斗破坏怪兽时
	e4:SetCondition(aux.bdcon)
	e4:SetTarget(c78509901.sptg2)
	e4:SetOperation(c78509901.spop2)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上表侧表示且可以送去墓地的「方界」怪兽
function c78509901.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤规则的条件判定函数
function c78509901.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有满足送墓条件的表侧表示「方界」怪兽
	local mg=Duel.GetMatchingGroup(c78509901.filter,tp,LOCATION_MZONE,0,nil)
	-- 检查是否能选出2只怪兽，且送去墓地后有足够的怪兽区域用于特殊召唤
	return mg:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
-- 特殊召唤规则的释放/送墓卡片选择函数
function c78509901.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足送墓条件的表侧表示「方界」怪兽
	local mg=Duel.GetMatchingGroup(c78509901.filter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择2只送去墓地后能腾出足够怪兽区域的「方界」怪兽
	local sg=mg:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的具体执行与后续效果处理函数
function c78509901.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽作为特殊召唤的消耗送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
	-- ①：这个方法特殊召唤的这张卡的攻击力上升2000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(2000)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 过滤条件：墓地中的「方界胤 毗贾姆」且可以特殊召唤
function c78509901.spfilter(c,e,tp)
	return c:IsCode(15610297) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备与目标选择函数
function c78509901.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c78509901.spfilter(chkc,e,tp) end
	-- 在发动阶段，检查这张卡离开场后是否至少有1个可用的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler(),tp)>0
		-- 并且自己墓地存在至少1只可以特殊召唤的「方界胤 毗贾姆」
		and Duel.IsExistingTarget(c78509901.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ft=3
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 计算这张卡离开场后，最多可以特殊召唤的怪兽数量（上限为3）
	ft=math.min(ft,(Duel.GetMZoneCount(tp,e:GetHandler(),tp)))
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1到ft只「方界胤 毗贾姆」作为效果对象
	local g=Duel.SelectTarget(tp,c78509901.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置连锁信息，表明此效果包含特殊召唤选中的怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 过滤条件：卡组中的「方界超兽 破坏之乾闼尔」且可以加入手卡
function c78509901.thfilter(c)
	return c:IsCode(4998619) and c:IsAbleToHand()
end
-- 效果③的具体效果处理函数
function c78509901.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果这张卡已不在场或未能成功送去墓地，则不处理后续效果
	if not c:IsRelateToEffect(e) or Duel.SendtoGrave(c,REASON_EFFECT)==0 then return end
	-- 获取当前自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取作为效果对象且仍符合条件的墓地怪兽
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将选中的「方界胤 毗贾姆」以表侧表示特殊召唤，若成功召唤则继续处理
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取卡组中所有的「方界超兽 破坏之乾闼尔」
		local g=Duel.GetMatchingGroup(c78509901.thfilter,tp,LOCATION_DECK,0,nil)
		-- 如果卡组中存在该卡，询问玩家是否将其加入手卡
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(78509901,0)) then  --"是否把1只「方界超兽 破坏之乾闼尔」加入手卡？"
			-- 中断当前效果处理，使后续的检索手卡处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			g=g:Select(tp,1,1,nil)
			-- 将选中的「方界超兽 破坏之乾闼尔」加入玩家手卡
			Duel.SendtoHand(g,tp,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
