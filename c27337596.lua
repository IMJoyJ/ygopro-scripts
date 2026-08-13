--聖刻龍王－アトゥムス
-- 效果：
-- 龙族6星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从卡组选1只龙族怪兽，攻击力·守备力变成0特殊召唤。这个效果发动的回合，这张卡不能攻击。
function c27337596.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用等级6的龙族怪兽2只作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),6,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从卡组选1只龙族怪兽，攻击力·守备力变成0特殊召唤。这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27337596,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c27337596.spcost)
	e1:SetTarget(c27337596.sptg)
	e1:SetOperation(c27337596.spop)
	c:RegisterEffect(e1)
end
-- 发动代价的检查：自己本回合尚未攻击宣言过，且可以移除这张卡的1个超量素材作为发动代价。
function c27337596.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义特殊召唤的过滤条件：选出卡组中龙族且能被当前效果特殊召唤的怪兽（若是源数龙则需满足其特殊召唤手续）。
function c27337596.spfilter(c,e,tp)
	-- 检查卡片种族为龙族，并判断其能否被当前效果特殊召唤（源数龙需满足其额外召唤条件）。
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DragonXyzSpSummonType(c))
end
-- 发动目标的检查：自己主要怪兽区有空位，且卡组中存在满足特殊召唤条件的龙族怪兽。
function c27337596.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足spfilter过滤条件的龙族怪兽。
		and Duel.IsExistingMatchingCard(c27337596.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：效果处理时将把卡组的1只怪兽特殊召唤，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若场上无空位则直接结束；否则提示玩家从卡组选择1只符合条件的龙族怪兽，将其攻击力·守备力变成0特殊召唤，若是源数龙则完成其特殊召唤程序，最后完成特殊召唤。
function c27337596.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区仍有空位，否则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1张满足spfilter条件的龙族怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c27337596.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选到对象，则尝试将其表侧表示特殊召唤到自己主要怪兽区，并允许源数龙的特殊召唤手续。
	if tc and Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,aux.DragonXyzSpSummonType(tc),POS_FACEUP) then
		-- 攻击力·守备力变成0特殊召唤（此处实现攻击力变成0）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
		-- 若选择的怪兽是源数龙（满足其特殊召唤手续条件），则调用CompleteProcedure完成其特殊召唤规则程序。
		if aux.DragonXyzSpSummonType(tc) then
			tc:CompleteProcedure()
		end
	end
	-- 完成整个特殊召唤流程，将步骤中特殊召唤的怪兽正式放置到场上。
	Duel.SpecialSummonComplete()
end
