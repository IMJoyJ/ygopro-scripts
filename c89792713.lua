--極星宝レーヴァテイン
-- 效果：
-- 选择这个回合战斗破坏怪兽的场上表侧表示存在的1只怪兽才能发动。选择的怪兽破坏。不能对应这张卡的发动把魔法·陷阱·效果怪兽的效果发动。
function c89792713.initial_effect(c)
	-- 选择这个回合战斗破坏怪兽的场上表侧表示存在的1只怪兽才能发动。选择的怪兽破坏。不能对应这张卡的发动把魔法·陷阱·效果怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c89792713.target)
	e1:SetOperation(c89792713.activate)
	c:RegisterEffect(e1)
	if not c89792713.global_check then
		c89792713.global_check=true
		-- 选择这个回合战斗破坏怪兽的场上表侧表示存在的1只怪兽才能发动。选择的怪兽破坏。不能对应这张卡的发动把魔法·陷阱·效果怪兽的效果发动。
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_BATTLE_DESTROYING)
		ge:SetOperation(c89792713.checkop)
		-- 将全局效果注册给系统，用于在决斗中持续监测并记录战斗破坏怪兽的卡片
		Duel.RegisterEffect(ge,0)
	end
end
-- 全局效果的操作函数：当有怪兽被战斗破坏时，给进行战斗破坏且在场上表侧表示存在的怪兽注册一个持续到回合结束的标记
function c89792713.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsFaceup() and tc:IsRelateToBattle() then
			tc:RegisterFlagEffect(89792713,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end
-- 过滤条件：场上表侧表示存在且在本回合内注册了战斗破坏怪兽标记的怪兽
function c89792713.filter(c)
	return c:IsFaceup() and c:GetFlagEffect(89792713)~=0
end
-- 效果发动的靶向处理：验证是否存在合法目标，选择目标，设置破坏操作信息，并限制不能对应此卡的发动进行连锁
function c89792713.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c89792713.filter(chkc) end
	-- 在发动时进行可行性检查，判断场上是否存在至少1只满足条件的表侧表示怪兽可以作为对象
	if chk==0 then return Duel.IsExistingTarget(c89792713.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家发送提示信息，提示其选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动效果的玩家选择1只满足条件的场上表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c89792713.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，表明此效果的处理分类为破坏，目标为选中的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设定连锁限制，使得任何玩家都不能对应这张卡的发动把魔法·陷阱·效果怪兽的效果发动
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 效果处理函数：获取选中的对象，若其仍在场上表侧表示存在且仍是该效果的对象，则将其破坏
function c89792713.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
