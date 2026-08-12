--ディメンション・スライド
-- 效果：
-- 自己场上有怪兽特殊召唤时才能发动。选择对方场上表侧表示存在的1只怪兽从游戏中除外。那次特殊召唤是超量召唤的场合，这张卡可以在盖放的回合发动。
function c73632127.initial_effect(c)
	-- 自己场上有怪兽特殊召唤时才能发动。选择对方场上表侧表示存在的1只怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c73632127.condition)
	e1:SetTarget(c73632127.target)
	e1:SetOperation(c73632127.activate)
	c:RegisterEffect(e1)
	-- 那次特殊召唤是超量召唤的场合，这张卡可以在盖放的回合发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73632127,0))  --"适用「次元崩落」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(c73632127.actcon)
	c:RegisterEffect(e2)
end
-- 判定特殊召唤成功的怪兽中是否存在自己场上的怪兽
function c73632127.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp)
end
-- 过滤对方场上表侧表示且可以被除外的怪兽
function c73632127.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果发动的对象选择与操作信息设置
function c73632127.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c73632127.filter(chkc) end
	-- 判定对方场上是否存在可作为对象的表侧表示且可除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(c73632127.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 在系统提示框中显示“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只表侧表示且可除外的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73632127.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理的操作信息为除外该目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理，将选中的对象怪兽除外
function c73632127.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判定盖放回合发动的条件：特殊召唤的怪兽仅有1只且该召唤为超量召唤
function c73632127.actcon(e)
	-- 检查当前是否处于特殊召唤成功的时点，并获取触发该时点的信息
	local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if res then
		return teg:GetCount()==1 and teg:GetFirst():IsSummonType(SUMMON_TYPE_XYZ)
	end
end
