--幻妖種ミトラ
-- 效果：
-- 把这张卡作为同调素材的场合，不是地属性怪兽的同调召唤不能使用。自己的主要阶段时，选择场上1只地属性怪兽才能发动。选择的怪兽的等级下降1星。「幻妖种 密多罗」的效果1回合可以使用最多2次。
function c51912531.initial_effect(c)
	-- 把这张卡作为同调素材的场合，不是地属性怪兽的同调召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c51912531.synlimit)
	c:RegisterEffect(e1)
	-- 自己的主要阶段时，选择场上1只地属性怪兽才能发动。选择的怪兽的等级下降1星。「幻妖种 密多罗」的效果1回合可以使用最多2次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51912531,0))  --"等级下降1"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(2,51912531)
	e2:SetTarget(c51912531.target)
	e2:SetOperation(c51912531.operation)
	c:RegisterEffect(e2)
end
-- 设置该卡不能被作为同调素材，除非是地属性怪兽。
function c51912531.synlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 筛选场上的表侧表示、地属性且等级不低于2的怪兽。
function c51912531.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevelAbove(2)
end
-- 选择目标：选择场上1只符合条件的地属性怪兽。
function c51912531.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c51912531.filter(chkc) end
	-- 检查是否有符合条件的目标怪兽存在。
	if chk==0 then return Duel.IsExistingTarget(c51912531.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择一张表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从场上选择一只符合条件的地属性怪兽作为效果对象。
	Duel.SelectTarget(tp,c51912531.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 将选中的目标怪兽等级下降1星。
function c51912531.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给目标怪兽添加一个等级-1的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
