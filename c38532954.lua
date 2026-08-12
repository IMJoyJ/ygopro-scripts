--F.A.ピットストップ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「方程式运动员」怪兽为对象才能发动。那只怪兽的等级下降2星，自己从卡组抽出自己墓地的「方程式运动员进站」的数量＋1张。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「方程式运动员」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c38532954.initial_effect(c)
	-- ①：以自己场上1只「方程式运动员」怪兽为对象才能发动。那只怪兽的等级下降2星，自己从卡组抽出自己墓地的「方程式运动员进站」的数量＋1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38532954)
	e1:SetTarget(c38532954.target)
	e1:SetOperation(c38532954.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「方程式运动员」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38532954,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,38532955)
	-- 设置效果条件：这张卡送去墓地的回合不能发动这个效果
	e2:SetCondition(aux.exccon)
	-- 设置效果代价：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c38532954.sptg)
	e2:SetOperation(c38532954.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：返回场上正面表示的「方程式运动员」怪兽且等级大于等于3的怪兽
function c38532954.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107) and c:IsLevelAbove(3)
end
-- 效果处理函数：设置效果目标为场上正面表示的「方程式运动员」怪兽且等级大于等于3的怪兽
function c38532954.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c38532954.filter(chkc) end
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查场上是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c38532954.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 选择场上正面表示的「方程式运动员」怪兽且等级大于等于3的怪兽作为效果对象
	Duel.SelectTarget(tp,c38532954.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 统计当前玩家墓地里「方程式运动员进站」的数量
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,38532954)
	-- 设置效果处理信息：抽卡数量为墓地「方程式运动员进站」数量+1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct+1)
end
-- 效果处理函数：将选中的怪兽等级下降2星，并让玩家抽卡
function c38532954.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取当前效果的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算需要抽卡的数量
	local d=Duel.GetMatchingGroupCount(Card.IsCode,p,LOCATION_GRAVE,0,nil,38532954)+1
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsLevelAbove(3) and not tc:IsImmuneToEffect(e) then
		-- 创建等级下降2星的效果并注册到目标怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 让目标玩家从卡组抽指定数量的卡
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
-- 过滤函数：返回可以特殊召唤的「方程式运动员」怪兽
function c38532954.spfilter(c,e,tp)
	return c:IsSetCard(0x107) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：设置效果目标为墓地的「方程式运动员」怪兽
function c38532954.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c38532954.spfilter(chkc,e,tp) end
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c38532954.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地的「方程式运动员」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c38532954.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤指定数量的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将选中的怪兽特殊召唤
function c38532954.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
