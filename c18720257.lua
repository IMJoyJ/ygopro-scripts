--天気予報
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②③的效果1回合各能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组选1张「天气」魔法·陷阱卡在自己的魔法与陷阱区域表侧表示放置。
-- ②：自己把「天气」连接怪兽连接召唤的场合，可以让自己的魔法与陷阱区域的表侧表示的「天气」卡作为「天气」怪兽来成为连接素材。
-- ③：自己主要阶段才能发动。从手卡把1只「天气」怪兽召唤。
local s,id,o=GetID()
-- 创建并注册「天气预报」的三个效果：①发动时的检索放置「天气」魔陷效果；②让己方魔陷区表侧「天气」卡可作为「天气」连接素材的永续效果；③主要阶段从手卡召唤「天气」怪兽的起动效果。
function c18720257.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组选1张「天气」魔法·陷阱卡在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,18720257+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c18720257.activate)
	c:RegisterEffect(e1)
	-- ②：自己把「天气」连接怪兽连接召唤的场合，可以让自己的魔法与陷阱区域的表侧表示的「天气」卡作为「天气」怪兽来成为连接素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetCountLimit(1,18720257+o)
	e2:SetTarget(c18720257.mattg)
	e2:SetValue(c18720257.matval)
	c:RegisterEffect(e2)
	-- ③：自己主要阶段才能发动。从手卡把1只「天气」怪兽召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18720257,0))
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,18720257+o*2)
	e3:SetTarget(c18720257.sumtg)
	e3:SetOperation(c18720257.sumop)
	c:RegisterEffect(e3)
end
-- 定义①效果的卡组过滤条件：选择非场地且卡名含「天气」的魔法·陷阱卡，且该卡未被禁止、能通过场上同名卡唯一性检查。
function c18720257.tffilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_FIELD) and c:IsSetCard(0x109)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ①效果发动时的处理：从卡组挑选符合条件的「天气」魔法·陷阱卡，在魔陷区有空位且玩家确认后选择1张，以表侧表示放置到自己的魔法与陷阱区域。
function c18720257.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方卡组中满足tffilter条件的「天气」魔法·陷阱卡的集合。
	local g=Duel.GetMatchingGroup(c18720257.tffilter,tp,LOCATION_DECK,0,nil,tp)
	-- 判断是否存在可选的卡、己方魔陷区是否有空位且玩家是否确认放置，三者满足才继续执行放置处理。
	if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(18720257,1)) then  --"是否选「天气」魔法·陷阱卡放置？"
		-- 向玩家发送选择卡片提示，要求从候选卡中选择一张要放置到场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的「天气」魔法·陷阱卡以表侧表示移动到己方魔法与陷阱区域，并立即适用该卡的效果。
		Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
-- 判定该卡是否可作为额外连接素材：必须是卡名含「天气」的卡，且位于己方主要魔陷区域（序号0-4，不含场地魔法格）。
function c18720257.mattg(e,c)
	return c:IsSetCard(0x109) and c:GetSequence()<5
end
-- 判定「天气」连接怪兽进行连接召唤时，是否可将己方魔陷区表侧「天气」卡作为「天气」怪兽代替连接素材：仅当连接怪兽卡名含「天气」且效果持有者为己方时返回允许。
function c18720257.matval(e,lc,mg,c,tp)
	if not (lc:IsSetCard(0x109) and e:GetHandlerPlayer()==tp) then return false,nil end
	return true,true
end
-- 判断手卡怪兽是否可作为③效果召唤的对象：卡名含「天气」且能够进行通常召唤（本次调用忽略召唤次数限制、不检查额外祭品）。
function c18720257.sumfilter(c)
	return c:IsSetCard(0x109) and c:IsSummonable(true,nil)
end
-- ③效果的发动条件与操作信息登记：我方主要阶段若手卡存在满足sumfilter的「天气」怪兽，则效果可发动，并登记将进行1只怪兽的通常召唤。
function c18720257.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）确认手卡是否存在至少1只满足sumfilter的「天气」怪兽，作为能否发动的判定条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c18720257.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置本次效果处理的操作信息：处理类别为召唤（CATEGORY_SUMMON），预计处理1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ③效果实际处理：从手卡选择1只满足条件的「天气」怪兽，以无视通常召唤次数限制的方式进行通常召唤。
function c18720257.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择召唤怪兽的提示，要求其选择要召唤的「天气」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手卡中选出1只满足sumfilter的「天气」怪兽作为本次召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c18720257.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的「天气」怪兽以不占用每回合通常召唤次数的方式通常召唤到己方场上。
		Duel.Summon(tp,tc,true,nil)
	end
end
