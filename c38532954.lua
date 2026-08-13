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
	-- 设置②效果的发动条件：这张卡送去墓地的回合不能发动（通过 aux.exccon 判断）。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c38532954.sptg)
	e2:SetOperation(c38532954.spop)
	c:RegisterEffect(e2)
end
-- 定义①效果可选对象的过滤条件：自己场上表侧表示、属于「方程式运动员」字段且等级在3以上的怪兽。
function c38532954.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107) and c:IsLevelAbove(3)
end
-- ①效果的取对象合法性判断：指定对象时必须位于自己怪兽区且满足过滤条件；发动时还需确认自己可以抽卡且场上存在可选目标。
function c38532954.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c38532954.filter(chkc) end
	-- 发动①效果时确认玩家可以进行抽卡（效果需要抽卡）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 确认自己场上存在至少1只符合条件的「方程式运动员」怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c38532954.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 让玩家从自己场上选择1只符合条件的「方程式运动员」怪兽作为效果对象。
	Duel.SelectTarget(tp,c38532954.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将抽卡的对象玩家设置为效果发动者自身，后续抽卡由该玩家执行。
	Duel.SetTargetPlayer(tp)
	-- 统计自己墓地中卡名为「方程式运动员进站」的卡的数量，用于计算抽卡数。
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,38532954)
	-- 向系统登记后续将进行抽卡操作，抽卡数为墓地「方程式运动员进站」数量+1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct+1)
end
-- ①效果处理：若对象怪兽仍与效果关联且为表侧、等级不低于3、不免疫此效果，则令其等级下降2星，并让对象玩家从卡组抽取（墓地「方程式运动员进站」数量+1）张卡。
function c38532954.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 从当前连锁信息中取得要抽卡的玩家（即效果发动者）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新统计该玩家墓地中「方程式运动员进站」的数量，并加1得到抽卡数。
	local d=Duel.GetMatchingGroupCount(Card.IsCode,p,LOCATION_GRAVE,0,nil,38532954)+1
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsLevelAbove(3) and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的等级下降2星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 让玩家 p 以效果原因抽取 d 张卡。
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
-- 定义②效果可选对象的过滤条件：墓地中属于「方程式运动员」字段且能够被特殊召唤的怪兽。
function c38532954.spfilter(c,e,tp)
	return c:IsSetCard(0x107) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的取对象合法性判断：指定对象时必须位于自己墓地且满足过滤条件；发动时还需确认自己场上有空位且存在可特殊召唤的目标。
function c38532954.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c38532954.spfilter(chkc,e,tp) end
	-- 确认自己场上有可以特殊召唤怪兽的可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地存在至少1只符合条件的「方程式运动员」怪兽可以作为特殊召唤对象。
		and Duel.IsExistingTarget(c38532954.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送选择提示消息，提示需要选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「方程式运动员」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c38532954.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向系统登记后续将进行特殊召唤操作，对象为所选怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：若对象怪兽仍与效果关联，则将其以表侧表示特殊召唤到自己场上。
function c38532954.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到发动者自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
