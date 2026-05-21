--ダーク・アドバンス
-- 效果：
-- 「暗黑上级召唤」在1回合只能发动1张。
-- ①：自己·对方的主要阶段以及战斗阶段，以自己墓地1只攻击力2400以上而守备力1000的怪兽为对象才能发动。那只怪兽加入手卡。那之后，可以从手卡把1只攻击力2400以上而守备力1000的怪兽表侧攻击表示上级召唤。
function c97001138.initial_effect(c)
	-- 「暗黑上级召唤」在1回合只能发动1张。①：自己·对方的主要阶段以及战斗阶段，以自己墓地1只攻击力2400以上而守备力1000的怪兽为对象才能发动。那只怪兽加入手卡。那之后，可以从手卡把1只攻击力2400以上而守备力1000的怪兽表侧攻击表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,97001138+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c97001138.condition)
	e1:SetTarget(c97001138.target)
	e1:SetOperation(c97001138.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：只能在自己或对方的主要阶段以及战斗阶段发动
function c97001138.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
-- 过滤条件：自己墓地中攻击力2400以上且守备力1000的怪兽
function c97001138.thfilter(c)
	return c:IsAttackAbove(2400) and c:IsDefense(1000) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义效果发动时的靶向处理：选择墓地中符合条件的怪兽作为对象，并声明回收手牌的操作信息
function c97001138.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c97001138.thfilter(chkc) end
	-- 发动检测：检查自己墓地是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c97001138.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c97001138.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤条件：手牌中攻击力2400以上且守备力1000的、可以进行上级召唤的怪兽
function c97001138.sumfilter(c)
	return c:IsAttackAbove(2400) and c:IsDefense(1000) and c:IsSummonable(true,nil,1)
end
-- 定义效果处理：将对象怪兽加入手牌，之后可以从手牌将1只符合条件的怪兽上级召唤
function c97001138.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用此效果，则将其加入手牌，并确认其已成功进入手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取手牌中所有符合上级召唤条件的怪兽
		local g=Duel.GetMatchingGroup(c97001138.sumfilter,tp,LOCATION_HAND,0,nil)
		-- 若手牌中存在符合条件的怪兽，询问玩家是否进行上级召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(97001138,0)) then  --"是否把怪兽上级召唤？"
			-- 中断当前效果，使后续的上级召唤处理与加入手牌不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要召唤的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			local sc=g:Select(tp,1,1,nil):GetFirst()
			-- 洗切玩家手牌
			Duel.ShuffleHand(tp)
			-- 让玩家对选中的怪兽进行上级召唤（至少使用1个祭品）
			Duel.Summon(tp,sc,true,nil,1)
		else
			-- 若不进行上级召唤，则直接洗切玩家手牌
			Duel.ShuffleHand(tp)
		end
	end
end
