--レスキュー・ウォリアー
-- 效果：
-- 这张卡的战斗发生的对自己的战斗伤害变成0。这张卡被战斗破坏的场合，选择对方场上表侧表示存在的1只原本持有者是自己的怪兽得到控制权。
function c70630741.initial_effect(c)
	-- 这张卡的战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡被战斗破坏的场合，选择对方场上表侧表示存在的1只原本持有者是自己的怪兽得到控制权。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70630741,0))  --"获得控制权"
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetTarget(c70630741.target)
	e2:SetOperation(c70630741.operation)
	c:RegisterEffect(e2)
end
-- 过滤出对方场上表侧表示、原本持有者是自己且可以改变控制权的怪兽
function c70630741.filter(c,tp)
	return c:IsFaceup() and c:GetOwner()==tp and c:IsControlerCanBeChanged()
end
-- 效果发动的目标选择，由于是必发效果，在发动时选择符合条件的对象并设置操作信息
function c70630741.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c70630741.filter(chkc,tp) end
	if chk==0 then return true end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只满足过滤条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c70630741.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置连锁的操作信息，表明该效果包含改变控制权的操作
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理，获取对象怪兽并在其符合条件时转移控制权给发动效果的玩家
function c70630741.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽的控制权转移给发动效果的玩家
		Duel.GetControl(tc,tp)
	end
end
