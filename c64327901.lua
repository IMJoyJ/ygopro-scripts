--百鬼羅刹大集会
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上的「哥布林」怪兽的攻击力上升自己场上的「哥布林」怪兽数量×300。
-- ②：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「哥布林」怪兽召唤。
-- ③：可以以自己场上2只「哥布林」怪兽为对象，从以下效果选择1个发动。
-- ●那之内1只的等级变成和另1只的等级相同。
-- ●那2只的等级变成各自的原本等级合计的等级。
local s,id,o=GetID()
-- 初始化函数，注册卡片发动、攻击力上升、追加召唤以及等级变化的效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己场上的「哥布林」怪兽的攻击力上升自己场上的「哥布林」怪兽数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置攻击力上升效果的影响对象为自己场上的「哥布林」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xac))
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ②：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「哥布林」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"使用「百鬼罗刹大集会」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 设置可以进行追加召唤的怪兽为「哥布林」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xac))
	c:RegisterEffect(e2)
	-- ③：可以以自己场上2只「哥布林」怪兽为对象，从以下效果选择1个发动。这个卡名的③的效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"等级变化"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「哥布林」卡
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xac)
end
-- 计算攻击力上升数值的函数
function s.atkval(e,c)
	-- 获取自己场上表侧表示的「哥布林」怪兽数量并乘以300
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_MZONE,0,nil)*300
end
-- 过滤条件：表侧表示、等级1以上且可以成为效果对象的「哥布林」怪兽
function s.lvfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0xac) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1) and c:IsCanBeEffectTarget(e)
end
-- ③的效果的发动准备，选择2只目标怪兽并让玩家选择要适用的效果分支
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.filter(chkc) and chkc:IsControler(tp) end
	-- 判定是否能选择自己场上2只满足条件的「哥布林」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,2,nil,e) end
	-- 选择自己场上2只「哥布林」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,2,2,nil,e)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	local lv1=tc1:GetLevel()
	local lv2=tc2:GetLevel()
	local op=aux.SelectFromOptions(tp,{lv1~=lv2,aux.Stringid(id,2)},{true,aux.Stringid(id,3)})  --"那之内1只的等级变成和另1只的等级相同/那2只的等级变成各自的原本等级合计的等级"
	e:SetLabel(op)
end
-- 过滤条件：表侧表示且仍与当前效果有关联的对象怪兽
function s.tgfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- ③的效果的处理，根据玩家的选择执行对应的等级变化效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍存在于场上的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.tgfilter,nil,e)
	if g:GetCount()<2 then return end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	local lv1=tc1:GetLevel()
	local lv2=tc2:GetLevel()
	if e:GetLabel()==1 then
		-- 提示玩家选择其中1只等级不变的怪兽（作为另1只怪兽等级变化的参照物）
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))  --"请选择另1只怪兽（等级不变）"
		local g1=g:Select(tp,1,1,nil)
		local lv=g1:GetFirst():GetLevel()
		local sc=(g-g1):GetFirst()
		-- ●那之内1只的等级变成和另1只的等级相同。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
	else
		local tc=g:GetFirst()
		while tc do
		-- ●那2只的等级变成各自的原本等级合计的等级。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_LEVEL)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(lv1+lv2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
		end
	end
end
