--ブラッドストーム
-- 效果：
-- 这张卡的攻击力上升自己场上表侧表示存在的鸟兽族怪兽数量×100的数值。自己场上有鸟兽族怪兽表侧表示3只以上存在的场合，可以把对方场上存在的1张魔法·陷阱卡破坏。这个效果1回合只能使用1次。
function c69695704.initial_effect(c)
	-- 这张卡的攻击力上升自己场上表侧表示存在的鸟兽族怪兽数量×100的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c69695704.atkval)
	c:RegisterEffect(e1)
	-- 自己场上有鸟兽族怪兽表侧表示3只以上存在的场合，可以把对方场上存在的1张魔法·陷阱卡破坏。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69695704,0))  --"魔陷破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c69695704.descon)
	e2:SetTarget(c69695704.destg)
	e2:SetOperation(c69695704.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的鸟兽族怪兽
function c69695704.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WINDBEAST)
end
-- 攻击力上升值计算函数
function c69695704.atkval(e,c)
	-- 返回自己场上表侧表示的鸟兽族怪兽数量乘以100的数值
	return Duel.GetMatchingGroupCount(c69695704.cfilter,c:GetControler(),LOCATION_MZONE,0,nil)*100
end
-- 破坏效果的发动条件函数
function c69695704.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在3只或以上表侧表示的鸟兽族怪兽
	return Duel.IsExistingMatchingCard(c69695704.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
-- 过滤条件：魔法或陷阱卡
function c69695704.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的发动目标选择与检测函数
function c69695704.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c69695704.filter(chkc) end
	-- 效果发动时的可行性检查：对方场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c69695704.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c69695704.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，表示该效果的处理为破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行函数
function c69695704.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时进行条件检查，若自己场上表侧表示的鸟兽族怪兽不足3只则不处理
	if not Duel.IsExistingMatchingCard(c69695704.cfilter,tp,LOCATION_MZONE,0,3,nil) then return end
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏作为对象的卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
