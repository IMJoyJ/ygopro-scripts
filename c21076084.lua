--トリックスター・リンカーネイション
-- 效果：
-- ①：对方手卡全部除外，对方抽出那个数量。
-- ②：把墓地的这张卡除外，以自己墓地1只「淘气仙星」怪兽为对象才能发动。那只怪兽特殊召唤。
function c21076084.initial_effect(c)
	-- ①：对方手卡全部除外，对方抽出那个数量。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c21076084.target)
	e1:SetOperation(c21076084.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「淘气仙星」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21076084,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	-- 为②效果设置发动代价：把墓地中的这张卡自身除外（作为发动COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c21076084.sptg)
	e2:SetOperation(c21076084.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件检查和操作信息预设：获取对方手牌并检查全部可除外、对方可抽卡，然后设置除外与抽卡的操作信息。
function c21076084.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方玩家（以tp视角的对方）手牌中的所有卡，作为本次要处理的集合g。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local gc=g:GetCount()
	-- 发动条件判定：对方手牌数大于0、对方所有手牌都能被除外，且对方玩家可以抽gc张卡。
	if chk==0 then return gc>0 and g:FilterCount(Card.IsAbleToRemove,nil)==gc and Duel.IsPlayerCanDraw(1-tp,gc) end
	-- 将“除外对方手牌”的操作信息写入连锁，供其他卡牌效果连锁检测使用（如星尘龙）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,gc,0,0)
	-- 将“对方抽卡”的操作信息写入连锁，目标玩家为对方，预计抽卡数量为gc。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,gc)
end
-- 效果①的处理函数：再次获取对方手牌并全部除外，若实际除外数量大于0，则对方抽出相同数量的卡。
function c21076084.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方当前手牌组，用于效果处理时确认实际仍存在的手牌。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local gc=g:GetCount()
	if gc>0 and g:FilterCount(Card.IsAbleToRemove,nil)==gc then
		-- 将对方手牌全部以表侧表示除外，除外原因为效果（REASON_EFFECT）。
		local oc=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		if oc>0 then
			-- 让对方玩家抽出oc张卡（oc为实际除外的卡数量），抽卡原因为效果。
			Duel.Draw(1-tp,oc,REASON_EFFECT)
		end
	end
end
-- 定义②效果选择怪兽的过滤条件：卡名属于「淘气仙星」系列，且可以被当前效果特殊召唤。
function c21076084.spfilter(c,e,tp)
	return c:IsSetCard(0xfb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的取对象发动条件：检查自己主要怪兽区有空位，且墓地存在1只符合条件的「淘气仙星」怪兽；并规范取对象合法性。
function c21076084.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c21076084.spfilter(chkc,e,tp) end
	-- 检查自己场上主要怪兽区是否存在可用空格，若没有空格则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足spfilter过滤条件的「淘气仙星」怪兽，可作为效果对象。
		and Duel.IsExistingTarget(c21076084.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作者显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作者从自己墓地的符合条件的「淘气仙星」怪兽中选择1只，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c21076084.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将“特殊召唤对象怪兽”的操作信息写入连锁，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理函数：确认自己主要怪兽区仍有空格后，取回对象怪兽，若其仍与效果关联，则将其特殊召唤到自己场上。
function c21076084.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认自己主要怪兽区有空位，若没有空位则效果处理不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得当前连锁中登记的对象卡（即墓地的1只「淘气仙星」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上，无视召唤条件与苏生限制（参数false,false）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
