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
-- 作为同调素材限制的判定函数：若同调素材候选怪兽不是地属性，则不允许将其作为此卡的同调素材（即此卡作为同调素材时，只能用于地属性怪兽的同调召唤）。
function c51912531.synlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 效果对象筛选条件：怪兽需为表侧表示、地属性、等级2以上。
function c51912531.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevelAbove(2)
end
-- 效果的发动目标选择函数：负责检查能否选择符合条件的对象、向玩家发出选择提示，并让玩家选择1只场上表侧表示的地属性等级2以上的怪兽作为效果对象。
function c51912531.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c51912531.filter(chkc) end
	-- 发动条件判定：在发动时确认场上是否存在至少1只符合条件的表侧表示地属性怪兽（等级2以上）可以作为对象，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c51912531.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家发送选择提示消息，提示内容为‘请选择表侧表示的卡’，用于卡牌选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方场上选择1只符合条件的表侧表示地属性怪兽（等级2以上）作为效果对象，并将其登记为当前连锁的处理目标。
	Duel.SelectTarget(tp,c51912531.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时的实际操作：获取选择的目标怪兽，确认其仍表侧表示且与效果相关后，给该怪兽赋予等级下降1星的效果，该效果在怪兽离场等标准重置条件下失效。
function c51912531.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一个（也是唯一一个）效果对象，即选择的那只地属性怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的等级下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
