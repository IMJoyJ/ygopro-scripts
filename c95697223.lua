--竜の闘志
-- 效果：
-- ①：以这个回合特殊召唤的自己场上1只龙族怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中在通常攻击外加上可以作出最多有对方场上的这个回合特殊召唤的怪兽数量的攻击。
function c95697223.initial_effect(c)
	-- ①：以这个回合特殊召唤的自己场上1只龙族怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中在通常攻击外加上可以作出最多有对方场上的这个回合特殊召唤的怪兽数量的攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c95697223.target)
	e1:SetOperation(c95697223.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示、龙族且在本回合特殊召唤的怪兽
function c95697223.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsStatus(STATUS_SPSUMMON_TURN)
end
-- 效果的发动准备与合法性检测（包括判定是否满足发动条件以及是否能正确选择对象）
function c95697223.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c95697223.filter(chkc) end
	-- 检查自己场上是否存在符合条件的龙族怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c95697223.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在本回合特殊召唤的怪兽（数量大于0）
		and Duel.GetMatchingGroupCount(Card.IsStatus,tp,0,LOCATION_MZONE,nil,STATUS_SPSUMMON_TURN)>0 end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只在本回合特殊召唤的表侧表示龙族怪兽作为对象
	Duel.SelectTarget(tp,c95697223.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：获取对象怪兽与对方场上本回合特召怪兽数量，并为该怪兽赋予追加攻击的效果
function c95697223.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 计算对方场上在本回合特殊召唤的怪兽数量
	local ct=Duel.GetMatchingGroupCount(Card.IsStatus,tp,0,LOCATION_MZONE,nil,STATUS_SPSUMMON_TURN)
	if ct>0 and tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽在同1次的战斗阶段中在通常攻击外加上可以作出最多有对方场上的这个回合特殊召唤的怪兽数量的攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
