--強制進化
-- 效果：
-- 把自己场上1只名字带有「进化虫」的怪兽解放发动。从卡组把1只名字带有「进化龙」的怪兽特殊召唤。这个效果特殊召唤的怪兽变成当作用名字带有「进化虫」的怪兽的效果特殊召唤使用。
function c5338223.initial_effect(c)
	-- 把自己场上1只名字带有「进化虫」的怪兽解放发动。从卡组把1只名字带有「进化龙」的怪兽特殊召唤。这个效果特殊召唤的怪兽变成当作用名字带有「进化虫」的怪兽的效果特殊召唤使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c5338223.cost)
	e1:SetTarget(c5338223.target)
	e1:SetOperation(c5338223.activate)
	c:RegisterEffect(e1)
end
-- 定义可解放的进化虫过滤条件：必须卡名含有「进化虫」；且若主怪兽区已有空格则任意进化虫均可，若没有空格则必须是自己主怪兽区（序号<5）的进化虫才能解放；同时该怪兽的控制者是自己或是表侧表示。
function c5338223.cfilter(c,ft,tp)
	return c:IsSetCard(0x304e)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- 代价处理：设置标签1作为已支付代价标记，计算主怪兽区空格数；检查阶段确认存在可解放的进化虫；然后选择1只符合条件的进化虫并解放作为发动代价。
function c5338223.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 取得自己场上主怪兽区当前可用的空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在代价检查时，若主怪兽区空格数>-1且场上存在至少1只符合cfilter条件的可解放进化虫，则代价满足。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c5338223.cfilter,1,nil,ft,tp) end
	-- 从自己场上选择1只满足cfilter条件的进化虫作为解放对象。
	local rg=Duel.SelectReleaseGroup(tp,c5338223.cfilter,1,1,nil,ft,tp)
	-- 将选择的进化虫解放，解放原因记为COST（因此不会触发不受效果影响的免疫）。
	Duel.Release(rg,REASON_COST)
end
-- 定义特殊召唤对象的过滤条件：卡名含有「进化龙」，并且能以SUMMON_VALUE_EVOLTILE（即当作「进化虫」相关的效果特殊召唤）进行特殊召唤（检查召唤条件与苏生限制）。
function c5338223.spfilter(c,e,tp)
	return c:IsSetCard(0x604e) and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_EVOLTILE,tp,false,false)
end
-- 目标设置与发动条件判定：根据cost阶段留下的标签判断是否已解放过；若已解放则只需确认卡组存在可特殊召唤的进化龙，否则还需额外确认主怪兽区有空位；最后设置本次效果将进行特殊召唤的操作信息。
function c5338223.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查卡组中是否存在至少1只满足spfilter条件的「进化龙」怪兽。
			return Duel.IsExistingMatchingCard(c5338223.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		else
			-- 检查自己主怪兽区是否存在空格（用于特殊召唤）。
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 同时要求自己主怪兽区有空位，并且卡组中存在符合条件的「进化龙」怪兽。
				and Duel.IsExistingMatchingCard(c5338223.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		end
	end
	e:SetLabel(0)
	-- 设置效果处理信息：本次连锁将进行特殊召唤，预定从卡组特殊召唤1只怪兽到己方场上（对象在效果处理时确定，所以目标暂设为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理整体流程：若主怪兽区没有空格则直接终止；否则提示玩家选择要特殊召唤的卡，从卡组选出1只符合条件的「进化龙」，并以当作「进化虫」的效果特殊召唤的方式将其表侧表示特殊召唤到自己场上。
function c5338223.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时，若己方主怪兽区没有空格，则特殊召唤无法进行，效果处理失败。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向发动玩家显示选择提示，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选出1只满足spfilter条件的「进化龙」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c5338223.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「进化龙」以SUMMON_VALUE_EVOLTILE（当作「进化虫」的效果特殊召唤）方式特殊召唤到己方场上，表侧表示，并正常检查召唤条件和苏生限制。
		Duel.SpecialSummon(g,SUMMON_VALUE_EVOLTILE,tp,tp,false,false,POS_FACEUP)
	end
end
