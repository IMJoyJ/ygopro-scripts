--エクシーズ熱戦！！
-- 效果：
-- 自己场上的超量怪兽被战斗破坏时，支付1000基本分才能发动。双方玩家从各自的额外卡组选持有破坏的怪兽的阶级以下的阶级的1只超量怪兽给对方观看。把攻击力低的怪兽给人观看的玩家受到对方给人观看的怪兽的攻击力和自己给人观看的怪兽的攻击力的相差数值的伤害。对方没把怪兽给人观看的场合，给与对方基本分自己给人观看的怪兽的攻击力数值的伤害。
function c57319935.initial_effect(c)
	-- 自己场上的超量怪兽被战斗破坏时，支付1000基本分才能发动。双方玩家从各自的额外卡组选持有破坏的怪兽的阶级以下的阶级的1只超量怪兽给对方观看。把攻击力低的怪兽给人观看的玩家受到对方给人观看的怪兽的攻击力和自己给人观看的怪兽的攻击力的相差数值的伤害。对方没把怪兽给人观看的场合，给与对方基本分自己给人观看的怪兽的攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c57319935.condition)
	e1:SetCost(c57319935.cost)
	e1:SetTarget(c57319935.target)
	e1:SetOperation(c57319935.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上的超量怪兽被战斗破坏
function c57319935.cfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:IsPreviousControler(tp)
end
-- 发动条件：检查被战斗破坏的怪兽是否为自己场上的超量怪兽，并记录其阶级
function c57319935.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if c57319935.cfilter(tc,tp) then
		e:SetLabel(tc:GetRank())
		return true
	end
	tc=eg:GetNext()
	if tc and c57319935.cfilter(tc,tp) then
		e:SetLabel(tc:GetRank())
		return true
	end
	return false
end
-- 发动代价：支付1000基本分
function c57319935.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果目标：检查自己额外卡组是否存在阶级在被破坏怪兽阶级以下的超量怪兽
function c57319935.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在阶级在被破坏怪兽阶级以下的超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRankBelow,tp,LOCATION_EXTRA,0,1,nil,e:GetLabel()) end
end
-- 效果处理：双方玩家从各自额外卡组选择满足条件的超量怪兽给对方观看，并根据攻击力差值或是否观看计算伤害
function c57319935.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示自己选择一张超量怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(57319935,0))  --"请选择一张超量怪兽"
	-- 自己从额外卡组选择1只阶级在被破坏怪兽阶级以下的超量怪兽
	local tc1=Duel.SelectMatchingCard(tp,Card.IsRankBelow,tp,LOCATION_EXTRA,0,1,1,nil,e:GetLabel()):GetFirst()
	-- 提示对方选择一张超量怪兽
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(57319935,0))  --"请选择一张超量怪兽"
	-- 对方从额外卡组选择1只阶级在被破坏怪兽阶级以下的超量怪兽
	local tc2=Duel.SelectMatchingCard(1-tp,Card.IsRankBelow,1-tp,LOCATION_EXTRA,0,1,1,nil,e:GetLabel()):GetFirst()
	if tc1 and tc2 then
		-- 给对方确认自己选择的怪兽
		Duel.ConfirmCards(1-tp,tc1)
		-- 给自己确认对方选择的怪兽
		Duel.ConfirmCards(tp,tc2)
		local atk1=tc1:GetAttack()
		local atk2=tc2:GetAttack()
		if atk1>atk2 then
			-- 对方受到双方怪兽攻击力差值的伤害
			Duel.Damage(1-tp,atk1-atk2,REASON_EFFECT)
		elseif atk1<atk2 then
			-- 自己受到双方怪兽攻击力差值的伤害
			Duel.Damage(tp,atk2-atk1,REASON_EFFECT)
		end
	elseif tc1 then
		-- 给对方确认自己选择的怪兽
		Duel.ConfirmCards(1-tp,tc1)
		-- 对方受到自己展示怪兽攻击力数值的伤害
		Duel.Damage(1-tp,tc1:GetAttack(),REASON_EFFECT)
	elseif tc2 then
		-- 给自己确认对方选择的怪兽
		Duel.ConfirmCards(tp,tc2)
		-- 自己受到对方展示怪兽攻击力数值的伤害
		Duel.Damage(tp,tc2:GetAttack(),REASON_EFFECT)
	end
end
