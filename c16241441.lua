--C・ラーバ
-- 效果：
-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·火焰甲虫」。
function c16241441.initial_effect(c)
	-- 将卡号89621922（新空间侠·火焰甲虫）登记到这张卡的效果文本参考列表中，用于记录“这张卡上记载着另一张卡名”的事实，供规则判定及效果提示使用。
	aux.AddCodeList(c,89621922)
	-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·火焰甲虫」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16241441,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c16241441.spcon)
	e1:SetCost(c16241441.spcost)
	e1:SetTarget(c16241441.sptg)
	e1:SetOperation(c16241441.spop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件的判定函数，用于判断当前是否满足“场上有「新宇宙」存在”这一发动前提。
function c16241441.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前场上是否存在卡号42015635的「新宇宙」，若存在则返回真，该效果可以发动。
	return Duel.IsEnvironment(42015635)
end
-- 定义发动代价函数，用于确认这张卡自身是否可以解放，并实际支付解放自身的代价。
function c16241441.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡自身作为发动代价解放送入墓地（REASON_COST表示作为代价解放，不因效果破坏）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义筛选函数，用来从手卡·卡组中筛选出卡号89621922的「新空间侠·火焰甲虫」，且该卡可以被正常特殊召唤。
function c16241441.spfilter(c,e,tp)
	return c:IsCode(89621922) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的目标合法性检查函数，先确认主要怪兽区有可用空格（解放自身后可留出空位），再确认手卡·卡组中存在符合条件的特殊召唤对象。
function c16241441.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区可用数量是否大于-1（即至少可能有空位），作为效果可发动的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查我方手卡·卡组中是否存在至少1只满足spfilter条件的「新空间侠·火焰甲虫」，作为效果可发动的另一条件。
		and Duel.IsExistingMatchingCard(c16241441.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次连锁处理的操作信息设置为“特殊召唤”，数量为1，可能涉及的区域为手卡·卡组，供星尘龙等卡进行效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义效果处理时的执行函数，在效果结算时确认条件仍满足后，从手卡·卡组选择并特殊召唤「新空间侠·火焰甲虫」。
function c16241441.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查我方主要怪兽区是否有空位，若无空位则特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时再次检查「新宇宙」是否仍存在于场上，若已不存在则特殊召唤不处理。
	if not Duel.IsEnvironment(42015635) then return end
	-- 给操作者显示“请选择要特殊召唤的卡”的提示信息，引导玩家选择待特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从我方手卡·卡组中选择1只满足条件的「新空间侠·火焰甲虫」作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c16241441.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「新空间侠·火焰甲虫」以表侧攻击表示特殊召唤到持有者（我方）场上，成功时返回特殊召唤成功的数量。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
