--大波小波
-- 效果：
-- 自己场上表侧表示存在的水属性怪兽全破坏。之后，可以从手卡特殊召唤最多和破坏数同等数量的水属性怪兽上场。
function c51562916.initial_effect(c)
	-- 自己场上表侧表示存在的水属性怪兽全破坏。之后，可以从手卡特殊召唤最多和破坏数同等数量的水属性怪兽上场。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c51562916.target)
	e1:SetOperation(c51562916.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：判断怪兽是否表侧表示且属性为水属性，用于筛选己方场上要被破坏的怪兽。
function c51562916.dfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果发动时的目标函数：确认自己场上有表侧水属性怪兽存在，并登记本连锁的破坏对象信息，供发动检测与后续处理。
function c51562916.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：当 chk==0 时，检查己方场上是否存在至少1张表侧表示的水属性怪兽，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c51562916.dfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 取得己方场上所有表侧表示的水属性怪兽集合，作为本效果将破坏的候选对象。
	local g=Duel.GetMatchingGroup(c51562916.dfilter,tp,LOCATION_MZONE,0,nil)
	-- 将破坏效果的信息写入当前连锁操作信息：对象为上述集合，数量为集合内卡片数，声明将破坏这些卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义特殊召唤筛选函数：判断手牌中的怪兽是否水属性且可以被效果特殊召唤（包含苏生限制和召唤条件检查）。
function c51562916.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：破坏己方场上所有表侧水属性怪兽；若破坏数为0或没有可用怪兽区则结束。否则计算可特殊召唤数量（受可用怪兽区以及『青眼精灵龙』同时召唤限制影响，有该限制时最多1只），询问玩家后从手牌选择相应数量且满足条件的水属性怪兽表侧表示特殊召唤。
function c51562916.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取己方场上当前所有表侧表示的水属性怪兽集合，以实际存在的怪兽作为破坏对象。
	local g=Duel.GetMatchingGroup(c51562916.dfilter,tp,LOCATION_MZONE,0,nil)
	-- 以效果破坏上述怪兽集合，并记录实际破坏数量，用于确定后续可特殊召唤的数量上限。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 获取己方主要怪兽区域当前可用的空格数，作为特殊召唤数量上限之一。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct==0 or ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ct>ft then ct=ft end
	-- 获取手牌中所有满足水属性且可被特殊召唤的怪兽集合，作为玩家可选特殊召唤对象。
	local sg=Duel.GetMatchingGroup(c51562916.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 若手牌存在可选怪兽且玩家选择“是”确认发动特殊召唤，则进入特召处理；否则跳过特殊召唤。
	if sg:GetCount()~=0 and Duel.SelectYesNo(tp,aux.Stringid(51562916,0)) then  --"是否要特殊召唤水属性怪兽？"
		-- 中断当前效果处理，使后续特殊召唤与前面的破坏处理不同时进行，避免错误时点和同连锁效果触发。
		Duel.BreakEffect()
		-- 向玩家提示正在选择要特殊召唤的卡，选择界面显示“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local spg=sg:Select(tp,1,ct,nil)
		-- 将玩家选出的卡片以表侧攻击表示特殊召唤到己方场上（检查召唤条件与苏生限制），实现从手卡特殊召唤水属性怪兽。
		Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
	end
end
