--異次元ジェット・アイアン号
-- 效果：
-- 这张卡不能通常召唤。从自己的手卡·场上把「异次元超能人·星斗罗宾」「野兽战士 豹人」「凤王兽 铠楼罗」「铁巨人 大铁锤」各1只送去墓地的场合可以特殊召唤。此外，可以把自己场上的这张卡解放，选择自己墓地的「异次元超能人·星斗罗宾」「野兽战士 豹人」「凤王兽 铠楼罗」「铁巨人 大铁锤」各1只特殊召唤。
function c15574615.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己的手卡·场上把「异次元超能人·星斗罗宾」「野兽战士 豹人」「凤王兽 铠楼罗」「铁巨人 大铁锤」各1只送去墓地的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c15574615.spcon)
	e1:SetTarget(c15574615.sptg)
	e1:SetOperation(c15574615.spop)
	c:RegisterEffect(e1)
	-- 此外，可以把自己场上的这张卡解放，选择自己墓地的「异次元超能人·星斗罗宾」「野兽战士 豹人」「凤王兽 铠楼罗」「铁巨人 大铁锤」各1只特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15574615,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c15574615.cost)
	e2:SetTarget(c15574615.target)
	e2:SetOperation(c15574615.operation)
	c:RegisterEffect(e2)
end
-- 为四种指定怪兽的卡号创建检查函数列表，用于后续判断一组卡是否恰好包含这四张各1张。
c15574615.spchecks=aux.CreateChecks(Card.IsCode,{80208158,16796157,43791861,79185500})
-- 素材候选过滤条件：位于手牌或表侧表示的场上，可以作为代价送去墓地，且卡号是四种指定怪兽之一。
function c15574615.spcostfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
		and c:IsCode(80208158,16796157,43791861,79185500)
end
-- 特殊召唤规则的条件检查：从自己的手牌·场上寻找能够作为素材的卡，并判断能否选出四种指定怪兽各1只，且送墓后仍有可用的怪兽区空格来放置此卡。
function c15574615.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己手牌和场上所有满足素材送去墓地条件的指定怪兽候选组。
	local g=Duel.GetMatchingGroup(c15574615.spcostfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	-- 检查候选组中是否能选出一组卡，使四种指定怪兽各1张，并且送墓后自己场上仍有怪兽区空格。
	return g:CheckSubGroupEach(c15574615.spchecks,aux.mzctcheck,tp)
end
-- 特殊召唤规则的选择目标函数：提示玩家从候选组中选出四种指定怪兽各1张作为素材，保存至效果标签，供特殊召唤处理时送去墓地；选择成功才允许发动特召。
function c15574615.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己手牌和场上所有可作为素材送去墓地的指定怪兽候选组。
	local g=Duel.GetMatchingGroup(c15574615.spcostfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	-- 显示选择提示，让玩家选择要送去墓地的素材卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从候选组中选出四种指定怪兽各1张的一组素材，同时校验送墓后仍有怪兽区空格。
	local sg=g:SelectSubGroupEach(tp,c15574615.spchecks,true,aux.mzctcheck,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的操作函数：从效果标签取出之前选定的素材组，将其送去墓地，然后完成这张卡的特殊召唤。
function c15574615.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的四张素材卡全部送去墓地，作为这次特殊召唤的代价。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 起动效果的费用函数：检查这张卡是否可以被解放；当效果处理时将其解放作为发动代价。
function c15574615.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 把这张卡自身解放，作为发动第二个效果的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特召对象过滤条件：墓地中为四种指定怪兽之一，且可以被该效果特殊召唤，并能成为该效果的对象。
function c15574615.spfilter(c,e,tp)
	return c:IsCode(80208158,16796157,43791861,79185500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
-- 特殊召唤效果的目标函数：确认自己未被「青眼精灵龙」的禁止同时特召多只效果影响、拥有至少3个可用的怪兽区空格、且墓地中存在四种指定怪兽各1只；随后让玩家选择这4只对象并登记。
function c15574615.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中符合特召条件（指定卡号、可被特召、可成为对象）的怪兽候选组。
	local g=Duel.GetMatchingGroup(c15574615.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 发动条件之一：自己场上至少要有3个可用的怪兽区空格，才能配合解放自身后腾出的空位容纳4只特殊召唤的怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=3
		and g:CheckSubGroupEach(c15574615.spchecks)
	end
	-- 显示选择提示，让玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroupEach(tp,c15574615.spchecks)
	-- 将选中的4只怪兽登记为当前连锁的效果对象。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：本次连锁的特殊召唤对象为sg，数量为4。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,4,0,0)
end
-- 特殊召唤效果的操作函数：若「青眼精灵龙」效果适用则直接终止；否则取出仍与效果相关的对象卡，确认空位足够后以表侧攻击表示全部特殊召唤。
function c15574615.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 从当前连锁登记的对象卡中筛选出仍然与该效果相关（未被无效、未离场导致关系重置）的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 获取自己当前可用的主要怪兽区空格数，用于判断能否容纳4只怪兽。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if g:GetCount()>ft then return end
	-- 将选中的对象卡全部以表侧攻击表示特殊召唤到自己场上，无视召唤条件并解除苏生限制。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
