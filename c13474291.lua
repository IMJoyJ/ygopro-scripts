--雲魔物－ストーム・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。把自己墓地1只名字带有「云魔物」的怪兽从游戏中除外特殊召唤。这张卡不会被战斗破坏。这张卡表侧守备示在场上存在的场合，这张卡破坏。1回合只有1次，可以给场上1只怪兽放置1个雾指示物。
function c13474291.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡表侧守备示在场上存在的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c13474291.sdcon)
	c:RegisterEffect(e2)
	-- 把自己墓地1只名字带有「云魔物」的怪兽从游戏中除外特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c13474291.spcon)
	e3:SetTarget(c13474291.sptg)
	e3:SetOperation(c13474291.spop)
	c:RegisterEffect(e3)
	-- 1回合只有1次，可以给场上1只怪兽放置1个雾指示物。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(13474291,0))  --"放置指示物"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c13474291.cttg)
	e4:SetOperation(c13474291.ctop)
	c:RegisterEffect(e4)
end
c13474291.mentioned_counter={
	[0x1019]=true,
}
-- 定义自我破坏效果的触发条件函数，检查怪兽是否处于表侧守备位置
function c13474291.sdcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
-- 定义墓地云魔物怪兽的过滤条件：属于「云魔物」系列、怪兽卡且能作为代价除外
function c13474291.cfilter(c)
	return c:IsSetCard(0x18) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤时的效果发动条件判定函数，检查场上是否有空位以及墓地里是否存在符合条件的云魔物怪兽
function c13474291.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检索控制器在主要怪兽区的可用空格数，用于判断是否满足苏生位置要求
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 结合前一个条件，进一步验证墓地中是否存在至少一只符合过滤条件的云魔物怪兽
		and Duel.IsExistingMatchingCard(c13474291.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 定义特殊召唤效果的目标选择逻辑，从墓地的符合条件的怪兽中让玩家选定一只作为代价除去
function c13474291.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 检索墓地中的所有符合筛选条件的「云魔物」怪兽组成一个卡组对象
	local g=Duel.GetMatchingGroup(c13474291.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 弹出对话框或缓存提示信息，要求玩家确认选择哪张墓地怪兽进行除外特殊召唤
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义特殊召唤效果的最终处理逻辑，将选定的卡片从游戏中除外并计入特殊召唤原因
function c13474291.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 执行选定卡组的除外操作，将其从游戏中移出并标记为特殊召唤来源
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 定义起动效果的目标选择函数：筛选能够添加雾指示物的表侧表示怪兽作为对象
function c13474291.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x1019,1) end
	-- 检查场上是否至少有1只能够接受雾指示物的表侧表示怪兽，用于确定目标选择的有效性
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x1019,1) end
	-- 弹出对话框或缓存提示信息，指示玩家从场上的合法对象中选择一张卡片进行后续操作
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 执行最终的目标选择操作，将选定的怪兽设为当前效果的关联目标对象
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x1019,1)
end
-- 定义起动效果的结算逻辑，从连锁中获取第一张目标卡片并尝试向其添加雾指示物
function c13474291.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果关联的第一张目标卡片实例，以便进行后续的指示物添加操作
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1019,1)
	end
end
