--ベアルクティ－ポラリィ
-- 效果：
-- 这张卡不能同调召唤，等级差直到1为止从自己场上把调整1只和调整以外的怪兽1只送去墓地的场合才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从卡组选1张「北极天熊北斗星」发动。
-- ②：把自己场上1只7星以上的怪兽解放才能发动。从自己墓地选1只「北极天熊」怪兽加入手卡或特殊召唤。
function c27693363.initial_effect(c)
	-- 将卡号89264428（北天熊北斗星）登记为这张卡的卡名关联，用于代码列表处理或效果关联查询。
	aux.AddCodeList(c,89264428)
	c:EnableReviveLimit()
	-- 这张卡不能同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 等级差直到1为止从自己场上把调整1只和调整以外的怪兽1只送去墓地的场合才能特殊召唤。（此处为不入连锁的特殊召唤规则，处理素材选择与送去墓地）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c27693363.sprcon)
	e2:SetTarget(c27693363.sprtg)
	e2:SetOperation(c27693363.sprop)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤成功的场合才能发动。从卡组选1张「北极天熊北斗星」发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27693363,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,27693363)
	e3:SetTarget(c27693363.acttg)
	e3:SetOperation(c27693363.actop)
	c:RegisterEffect(e3)
	-- ②：把自己场上1只7星以上的怪兽解放才能发动。从自己墓地选1只「北极天熊」怪兽加入手卡或特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(27693363,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,27693364)
	e4:SetCost(c27693363.thcost)
	e4:SetTarget(c27693363.thtg)
	e4:SetOperation(c27693363.thop)
	c:RegisterEffect(e4)
end
-- 检查作为特殊召唤素材的怪兽是否满足：表侧表示、等级1以上、可以作为代价送去墓地。
function c27693363.tgrfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsAbleToGraveAsCost()
end
-- 在候选素材组g中检查是否存在另一只怪兽c，使得c与某张候选素材的等级差为1（即等级差直到1为止的条件）。
function c27693363.mnfilter(c,g)
	return g:IsExists(c27693363.mnfilter2,1,c,c)
end
-- 判断两张怪兽的等级差是否为1：c的等级减去mc的等级等于1。
function c27693363.mnfilter2(c,mc)
	return c:GetLevel()-mc:GetLevel()==1
end
-- 选择两张素材的过滤条件：仅选2张；其中至少1只是调整、至少1只是调整以外；两张等级差必须为1；并且额外卡组的这张卡有可用的特殊召唤区域。
function c27693363.fselect(g,tp,sc)
	return g:GetCount()==2
		-- 所选2张素材中必须至少有1只为调整怪兽，且至少有1只为调整以外的怪兽。
		and g:IsExists(Card.IsType,1,nil,TYPE_TUNER) and g:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_TUNER)
		and g:IsExists(c27693363.mnfilter,1,nil,g)
		-- 确认把这些素材从场上送墓后，额外卡组的这张卡仍有可用怪兽区域可以进行特殊召唤。
		and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
-- 特殊召唤规则效果的发动条件：若c为空则可用；否则以这张卡的控制者视角，在自己场上存在能满足素材选择条件的2张怪兽。
function c27693363.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 取得控制者场上所有满足素材候选条件（表侧、等级1以上、可作为代价送墓）的怪兽群。
	local g=Duel.GetMatchingGroup(c27693363.tgrfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c27693363.fselect,2,2,tp,c)
end
-- 特殊召唤规则效果发动时选择实际素材：从候选怪兽中选择2张满足fselect条件的卡，并通过KeepAlive保存到效果标签对象中，供处理时送去墓地。
function c27693363.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得控制者场上所有可作为素材的怪兽群（用于选择素材时使用）。
	local g=Duel.GetMatchingGroup(c27693363.tgrfilter,tp,LOCATION_MZONE,0,nil)
	-- 弹出选择提示，提示玩家从符合条件的怪兽中选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c27693363.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则效果处理：将之前保存在效果标签中的2张素材怪兽送去墓地，完成特殊召唤手续。
function c27693363.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local tg=e:GetLabelObject()
	-- 将选定的2张素材怪兽以特殊召唤手续（规则处理）为由送去墓地，作为这次特殊召唤的代价。
	Duel.SendtoGrave(tg,REASON_SPSUMMON)
	tg:DeleteGroup()
end
-- 这张卡的①效果可选目标：卡组中存在的「北极天熊北斗星」，且其作为场地魔法时当前玩家能够发动。
function c27693363.actfilter(c,tp)
	return c:IsCode(89264428) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- ①效果的发动条件：自己卡组中存在1张符合条件的「北极天熊北斗星」才能发动。
function c27693363.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认卡组中是否存在1张符合条件的「北极天熊北斗星」；若存在则效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c27693363.actfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- ①效果处理：从卡组选1张「北极天熊北斗星」，若场地区已有卡则先送墓，然后把这张场地魔法移动到场地区并作为发动该场地魔法处理。
function c27693363.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出操作提示，确认玩家要选择一张卡片进行操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1张符合条件的「北极天熊北斗星」用于发动。
	local g=Duel.SelectMatchingCard(tp,c27693363.actfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		local te=tc:GetActivateEffect()
		-- 获取玩家场上已有的场地魔法卡（场地区域第1格）。
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 把原有的场地区域卡（旧场地魔法）以规则理由送去墓地。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使场地卡送墓地与随后发动新场地效果视为不同时处理，避免错失时点。
			Duel.BreakEffect()
		end
		-- 把选出的「北极天熊北斗星」从卡组移动到玩家的场地区域，以表侧表示放置，并立刻适用其效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发该场地魔法卡的发动时点事件（4179255为事件码），使场地魔法的发动处理被正确连锁到当前链上。
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
-- 作为②效果解放代价的卡的过滤条件：等级7以上，并且是自己场上的怪兽（若对方场上表侧怪兽被选为代价则也可用）。
function c27693363.rfilter(c,tp)
	return c:IsLevelAbove(7) and (c:IsControler(tp) or c:IsFaceup())
end
-- 可以作为代替解放的额外候选卡：能够被除外，并且带有16471775或89264428（北极天熊北斗星）的代替解放效果。
function c27693363.excostfilter(c,tp)
	return c:IsAbleToRemove() and (c:IsHasEffect(16471775,tp) or c:IsHasEffect(89264428,tp))
end
-- 代价选择过滤：该候选卡被选为解放/代替除外后，墓地中存在至少1只符合条件的「北极天熊」怪兽，且若想特殊召唤则场上要有空位。
function c27693363.costfilter(c,e,tp)
	-- 计算该候选卡离场后自己场上是否还有至少1个怪兽区域，用于判断是否能把墓地的怪兽特殊召唤。
	local check=Duel.GetMZoneCount(tp,c)>0
	-- 检查墓地中是否有符合条件的「北极天熊」怪兽，且根据上述场上空位判断是否能进行加入手卡或特殊召唤。
	return Duel.IsExistingMatchingCard(c27693363.tgfilter,tp,LOCATION_GRAVE,0,1,c,e,tp,check)
end
-- ②效果的对象过滤：墓地中的「北极天熊」怪兽；可以加入手卡，或者（若场上有空位）可以以该效果特殊召唤。
function c27693363.tgfilter(c,e,tp,check)
	return c:IsSetCard(0x163) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ②效果发动代价：选择自己场上1只7星以上怪兽解放；也可以选带代替除外效果的卡（如北极天熊北斗星）除外来代替解放。
function c27693363.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可解放的怪兽，并筛选出等级7以上的卡。
	local g1=Duel.GetReleaseGroup(tp):Filter(c27693363.rfilter,nil,tp)
	-- 额外获取墓地中带有代替解放效果的卡（16471775或北极天熊北斗星），作为替代解放候补。
	local g2=Duel.GetMatchingGroup(c27693363.excostfilter,tp,LOCATION_GRAVE,0,nil,tp)
	g1:Merge(g2)
	if chk==0 then return g1:IsExists(c27693363.costfilter,1,nil,e,tp) end
	-- 弹出提示，让玩家选择要解放的怪兽或替代除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g1:FilterSelect(tp,c27693363.costfilter,1,1,nil,e,tp)
	local tc=rg:GetFirst()
	local te=tc:IsHasEffect(16471775,tp) or tc:IsHasEffect(89264428,tp)
	if te then
		te:UseCountLimit(tp)
		-- 若选择的是带有代替解放效果的卡，则把该卡除外（REASON_REPLACE代替）来替代怪兽解放作为cost。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		-- 若使用通常解放，调用辅助函数处理可能存在的额外释放次数限制（如暗影敌托邦等代替解放次数）。
		aux.UseExtraReleaseCount(rg,tp)
		-- 将选择的怪兽解放作为cost，理由为发动代价（REASON_COST）。
		Duel.Release(tc,REASON_COST)
	end
end
-- ②效果的发动条件：自己墓地中存在至少1只符合条件的「北极天熊」怪兽（可加入手卡或特殊召唤）时才能发动。
function c27693363.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查墓地中是否存在至少1只符合条件的「北极天熊」怪兽；check参数暂时预设为true，处理时再实际判定能否特殊召唤。
	if chk==0 then return Duel.IsExistingMatchingCard(c27693363.tgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,true) end
end
-- ②效果处理：从墓地选择1只「北极天熊」怪兽，玩家选择加入手卡（若不能特殊召唤则强制加入手卡）或特殊召唤。
function c27693363.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发动处理时再次确认自己场上是否有空余的怪兽区域，用于判断能否选择特殊召唤。
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 弹出提示，让玩家选择墓地中要操作的「北极天熊」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己墓地区域选择1只符合条件的「北极天熊」怪兽，同时过滤掉受“王家长眠之谷”效果影响不能从墓地移动的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27693363.tgfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,check)
	local tc=g:GetFirst()
	if tc then
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or not check
			-- 若目标既能加入手卡也能特殊召唤，由玩家选择处理方式；选项0为加入手卡（1190），选项1为特殊召唤（1152）。
			or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选择的「北极天熊」怪兽以效果理由送回持有者的手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		else
			-- 将选择的「北极天熊」怪兽以表侧表示特殊召唤到自己的场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
