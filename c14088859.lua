--ネオス・フュージョン
-- 效果：
-- ①：从自己的手卡·卡组·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把只以包含「元素英雄 新宇侠」的怪兽2只为素材的那1只融合怪兽无视召唤条件从额外卡组特殊召唤。这张卡的发动后，直到回合结束时自己不能把怪兽特殊召唤。
-- ②：需以「元素英雄 新宇侠」为融合素材的自己场上的融合怪兽被战斗·效果破坏的场合或者因自身的效果回到额外卡组的场合，可以作为代替把墓地的这张卡除外。
function c14088859.initial_effect(c)
	-- 将「元素英雄 新宇侠」的卡号89943723登记到本卡，使本卡在规则上被视为记载有该卡名，用于融合素材相关判定。
	aux.AddCodeList(c,89943723)
	-- 为本卡登记「元素英雄」系列字段（0x3008），用于支持与「元素英雄」系列怪兽相关的判定。
	aux.AddSetNameMonsterList(c,0x3008)
	-- ①：从自己的手卡·卡组·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把只以包含「元素英雄 新宇侠」的怪兽2只为素材的那1只融合怪兽无视召唤条件从额外卡组特殊召唤。这张卡的发动后，直到回合结束时自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14088859,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c14088859.target)
	e1:SetOperation(c14088859.activate)
	c:RegisterEffect(e1)
	-- ②：需以「元素英雄 新宇侠」为融合素材的自己场上的融合怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c14088859.reptg)
	e2:SetValue(c14088859.repval)
	e2:SetOperation(c14088859.repop)
	c:RegisterEffect(e2)
	-- 需以「元素英雄 新宇侠」为融合素材的自己场上的融合怪兽因自身的效果回到额外卡组的场合，可以作为代替把墓地的这张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(c14088859.reptg2)
	e3:SetOperation(c14088859.repop2)
	e3:SetValue(c14088859.repval2)
	c:RegisterEffect(e3)
end
-- 筛选可作为融合素材的怪兽：必须是怪兽卡、能被效果送去墓地，并且不免疫当前效果（免疫该效果的怪兽不能作为素材）。
function c14088859.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
-- 筛选可特殊召唤的融合怪兽：该融合怪兽的素材数必须是2、融合素材中包含「元素英雄 新宇侠」、可以无视召唤条件特殊召唤，并且可由当前素材组m完成融合召唤。
function c14088859.filter2(c,e,tp,m,chkf)
	-- 获取该融合怪兽的素材数下限和上限，用于判断是否为只需2只素材的融合怪兽。
	local min,max=aux.GetMaterialListCount(c)
	-- 判定该融合怪兽必须恰好需要2只素材，且其素材中包含「元素英雄 新宇侠」（卡号89943723），满足“只以包含新宇侠的怪兽2只为素材”。
	return min==2 and max==2 and aux.IsMaterialListCode(c,89943723)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:CheckFusionMaterial(m,nil,chkf,true)
end
-- 发动条件判定：检查己方额外卡组是否存在可用手卡·场上·卡组的素材融合召唤、素材数为2且含新宇侠的融合怪兽；若存在则设置特殊召唤的操作信息。
function c14088859.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp|0x200
		-- 检索己方手卡·场上·卡组中所有可作为融合素材的怪兽（filter1），存入mg组。
		local mg=Duel.GetMatchingGroup(c14088859.filter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,nil,e)
		-- 检查额外卡组是否存在至少1只满足filter2条件的融合怪兽，作为可特殊召唤的对象。
		return Duel.IsExistingMatchingCard(c14088859.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf)
	end
	-- 设置本次效果处理包含1次从额外卡组的特殊召唤，供连锁等信息判断使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从手卡·场上·卡组选择融合素材送入墓地，将选择的融合怪兽无视召唤条件从额外卡组特殊召唤；随后给自己附加直到回合结束不能特殊召唤怪兽的自肃效果。
function c14088859.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp|0x200
	-- 效果处理时重新获取己方手卡·场上·卡组中可作为融合素材的怪兽组。
	local mg=Duel.GetMatchingGroup(c14088859.filter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,nil,e)
	-- 获取额外卡组中所有满足特殊召唤条件的融合怪兽，作为候选组。
	local sg=Duel.GetMatchingGroup(c14088859.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,chkf)
	if sg:GetCount()>0 then
		-- 向玩家显示“请选择要特殊召唤的卡”的提示，用于选择融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 让玩家从候选素材组mg中为融合怪兽tc选择一组融合素材（须符合素材条件，包含新宇侠且共2只），并返回选中的素材组。
		local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf,true)
		-- 将选中的融合素材以效果原因送去墓地。
		Duel.SendtoGrave(mat,REASON_EFFECT)
		-- 中断当前效果处理，使素材送墓与随后的特殊召唤视为不同时处理，避免时点合并。
		Duel.BreakEffect()
		-- 将融合怪兽tc无视召唤条件（nocheck=true）、以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- ①：从自己的手卡·卡组·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把只以包含「元素英雄 新宇侠」的怪兽2只为素材的那1只融合怪兽无视召唤条件从额外卡组特殊召唤。这张卡的发动后，直到回合结束时自己不能把怪兽特殊召唤。②：需以「元素英雄 新宇侠」为融合素材的自己场上的融合怪兽被战斗·效果破坏的场合或者因自身的效果回到额外卡组的场合，可以作为代替把墓地的这张卡除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		-- 将自肃效果e1注册到场上，使tp玩家直到回合结束时不能特殊召唤怪兽。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义②代替破坏中，可被替代的融合怪兽条件：表侧表示、己方场上、怪兽区、融合怪兽、素材包含新宇侠、因战斗或效果被破坏且未被其他代替效果处理。
function c14088859.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_FUSION)
		-- 确认该融合怪兽的素材包含「元素英雄 新宇侠」，并且此次是因战斗或效果破坏，且不是由其他代替效果处理过。
		and aux.IsMaterialListCode(c,89943723) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- ②代替破坏的发动条件判断：墓地的这张卡可除外，且存在满足repfilter条件的被破坏融合怪兽；满足则询问玩家是否发动代替效果。
function c14088859.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c14088859.repfilter,1,nil,tp) end
	-- 询问玩家是否选择用墓地的这张卡代替融合怪兽被破坏。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 作为代替破坏的Value回调，判断被破坏的融合怪兽是否满足代替条件。
function c14088859.repval(e,c)
	return c14088859.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的处理：将墓地的这张卡除外，以代替融合怪兽被破坏。
function c14088859.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的「新宇融合」表侧除外，完成代替破坏的代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
-- 定义②回额外卡组代替中，可被替代的融合怪兽条件：己方场上、怪兽区、素材包含新宇侠的融合怪兽，且此次将因自身效果从场上返回额外卡组。
function c14088859.repfilter2(c,tp,re)
	-- 判断怪兽为己方控制、在怪兽区、为以新宇侠为素材的融合怪兽，满足作为代替对象的基本条件。
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and aux.IsMaterialListCode(c,89943723) and c:IsType(TYPE_FUSION)
		and c:GetDestination()==LOCATION_DECK and re:GetOwner()==c
end
-- ②回额外卡组代替的发动条件判断：存在怪兽将因自身效果回到额外卡组、墓地的这张卡可除外，且存在满足repfilter2条件的怪兽。
function c14088859.reptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return bit.band(r,REASON_EFFECT)~=0 and re
		and e:GetHandler():IsAbleToRemove() and eg:IsExists(c14088859.repfilter2,1,nil,tp,re) end
	-- 显示“是否除外「新宇融合」作为代替？”并询问玩家；选择“是”则发动代替除外。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(14088859,1)) then  --"是否除外「新宇融合」作为代替？"
		return true
	else return false end
end
-- 回额外卡组代替的处理：将墓地的这张卡除外，以代替融合怪兽回到额外卡组。
function c14088859.repop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的「新宇融合」表侧除外，完成回额外卡组代替的代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
-- 作为回额外卡组代替的Value回调，判断将被送去额外卡组的融合怪兽是否满足代替条件。
function c14088859.repval2(e,c)
	-- 判断怪兽是否为自己场上的以新宇侠为素材的融合怪兽，以决定是否允许用除外本卡代替其返回额外卡组。
	return c:IsControler(e:GetHandlerPlayer()) and c:IsLocation(LOCATION_MZONE) and aux.IsMaterialListCode(c,89943723) and c:IsType(TYPE_FUSION)
end
