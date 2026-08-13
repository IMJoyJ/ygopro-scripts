--影霊衣の万華鏡
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上1只怪兽解放或者作为解放的代替而把额外卡组1只怪兽送去墓地，从手卡把「影灵衣」仪式怪兽任意数量仪式召唤。
-- ②：自己场上没有怪兽存在的场合，从自己墓地把1只「影灵衣」怪兽和这张卡除外才能发动。从卡组把1张「影灵衣」魔法卡加入手卡。
function c51124303.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上1只怪兽解放或者作为解放的代替而把额外卡组1只怪兽送去墓地，从手卡把「影灵衣」仪式怪兽任意数量仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,51124303)
	e1:SetTarget(c51124303.target)
	e1:SetOperation(c51124303.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上没有怪兽存在的场合，从自己墓地把1只「影灵衣」怪兽和这张卡除外才能发动。从卡组把1张「影灵衣」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c51124303.thcon)
	e2:SetCost(c51124303.thcost)
	e2:SetTarget(c51124303.thtg)
	e2:SetOperation(c51124303.thop)
	c:RegisterEffect(e2)
end
-- 筛选可作为仪式召唤对象的「影灵衣」仪式怪兽：必须是「影灵衣」仪式怪兽，满足该怪兽自身附加的素材条件，且能由当前选择的素材mc作为仪式素材进行仪式召唤。
function c51124303.spfilter(c,e,tp,mc)
	local mg=Group.FromCards(mc)
	return c:IsSetCard(0xb4) and bit.band(c:GetType(),0x81)==0x81 and (not c.mat_filter or c.mat_filter(mc,tp)) and (not c.mat_group_check or c.mat_group_check(mg,tp))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
		and mc:IsCanBeRitualMaterial(c)
end
-- 检查素材mc的仪式等级是否与仪式怪兽c的等级匹配：取mc:GetRitualLevel(c)得到其作为c的仪式素材时可用的等级值（可能编码两个等级），排除默认等级情况后，若c的等级等于该值的高位或低位则允许作为解放。
function c51124303.rfilter(c,mc)
	local mlv=mc:GetRitualLevel(c)
	if mlv==mc:GetLevel() then return false end
	local lv=c:GetLevel()
	return lv==bit.band(mlv,0xffff) or lv==bit.rshift(mlv,16)
end
-- 判断候选素材c能否用于仪式召唤：取得手卡中可仪式召唤的「影灵衣」仪式怪兽，计算可用怪兽区空位（若c在场上则解放后增加1个，若受「青眼精灵龙」限制则最多1只），存在能通过c的仪式等级直接匹配的对象，或存在等级合计等于c的等级且数量不超过空位的对象组合。
function c51124303.filter(c,e,tp)
	-- 获取当前候选素材c可作为仪式素材的所有手卡「影灵衣」仪式怪兽（已过滤能否召唤）组成组sg。
	local sg=Duel.GetMatchingGroup(c51124303.spfilter,tp,LOCATION_HAND,0,c,e,tp,c)
	-- 获取我方主怪兽区当前可用空格数，作为仪式召唤可特殊召唤的怪兽数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if c:IsLocation(LOCATION_MZONE) then ft=ft+1 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	return sg:IsExists(c51124303.rfilter,1,nil,c) or sg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,ft)
end
-- 筛选可作为解放代替而送去墓地的额外卡组怪兽：必须是等级大于0且能被送去墓地的怪兽。
function c51124303.mfilter(c)
	return c:GetLevel()>0 and c:IsAbleToGrave()
end
-- 筛选可作为解放素材的自己场上怪兽：必须位于我方主怪兽区（序列0-4）且为我方控制，避免选择额外怪兽区的怪兽。
function c51124303.mzfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:GetSequence()<5
end
-- 效果①的发动条件检查：确认我方存在可用的仪式素材（手卡·场上怪兽或可代替解放的额外卡组怪兽），并且该素材能用于仪式召唤至少1只「影灵衣」仪式怪兽；若可以，则设置本次效果处理时涉及特殊召唤的信息。
function c51124303.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取我方主怪兽区可用空格数；若没有空格（格子为负数）则无法发动仪式召唤。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<0 then return false end
		-- 获取玩家tp可用的仪式素材组（包含手卡和场上的可解放怪兽以及墓地的仪式魔人等）。
		local mg=Duel.GetRitualMaterial(tp)
		if ft>0 then
			-- 从额外卡组中筛选可作为解放代替送去墓地的等级大于0的怪兽，并合并入仪式素材组。
			local mg2=Duel.GetMatchingGroup(c51124303.mfilter,tp,LOCATION_EXTRA,0,nil)
			mg:Merge(mg2)
		else
			mg=mg:Filter(c51124303.mzfilter,nil,tp)
		end
		return mg:IsExists(c51124303.filter,1,nil,e,tp)
	end
	-- 设置本次效果处理的信息：类别为特殊召唤，预计从手卡特殊召唤1只仪式怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 检查所选素材组的等级合计是否与目标仪式怪兽的等级（lv）完全相等。
function c51124303.RitualCheck(g,lv)
	return g:GetSum(Card.GetLevel)==lv
end
-- 生成附加检查函数：所选素材组的等级合计不能超过目标等级lv，用于在逐步选择任意数量素材时保证最终总等级不超出目标。
function c51124303.RitualCheckAdditional(lv)
	return	function(g)
				return g:GetSum(Card.GetLevel)<=lv
			end
end
-- 效果①的发动处理：选择1只解放/代替素材，然后从手卡选择1只或任意数量的「影灵衣」仪式怪兽进行仪式召唤，召唤数量受可用怪兽区空格数限制（青眼精灵龙在场时仅1只）；同时处理素材的解放或送墓。
function c51124303.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方主怪兽区当前可用空格数，若小于0则无法进行仪式召唤，直接结束。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<0 then return end
	::cancel::
	-- 获取当前可用的仪式素材组（手卡·场上可解放怪兽及墓地仪式魔人等）。
	local mg=Duel.GetRitualMaterial(tp)
	if ft>0 then
		-- 将额外卡组中可作为解放代替送去墓地的怪兽也加入可选素材组。
		local mg2=Duel.GetMatchingGroup(c51124303.mfilter,tp,LOCATION_EXTRA,0,nil)
		mg:Merge(mg2)
	else
		mg=mg:Filter(c51124303.mzfilter,nil,tp)
	end
	-- 向玩家提示“请选择要解放的卡”（实际选择范围包含额外卡组代替送墓的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local mat=mg:FilterSelect(tp,c51124303.filter,1,1,nil,e,tp)
	local mc=mat:GetFirst()
	if not mc then return end
	-- 获取以所选素材mc为仪式素材时，可从手卡仪式召唤的「影灵衣」仪式怪兽组。
	local sg=Duel.GetMatchingGroup(c51124303.spfilter,tp,LOCATION_HAND,0,mc,e,tp,mc)
	if mc:IsLocation(LOCATION_MZONE) then ft=ft+1 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local b1=sg:IsExists(c51124303.rfilter,1,nil,mc)
	local b2=sg:CheckWithSumEqual(Card.GetLevel,mc:GetLevel(),1,ft)
	-- 当存在可用素材mc的仪式等级直接匹配的仪式怪兽，且（无等级合计匹配对象或玩家确认选择按该等级解放）时，采用单只仪式召唤方式；否则进入等级合计选择多只仪式怪兽的流程。
	if b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(51124303,0))) then  --"是否作为仪式召唤需要的等级数值的解放使用？"
		-- 向玩家提示“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=sg:Filter(c51124303.rfilter,nil,mc):SelectUnselect(nil,tp,false,true,1,1)
		if not tc then goto cancel end
		tc:SetMaterial(mat)
		if not mc:IsLocation(LOCATION_EXTRA) then
			-- 将选择的素材（手卡或场上怪兽）作为仪式召唤的解放处理。
			Duel.ReleaseRitualMaterial(mat)
		else
			-- 将选择的额外卡组怪兽代替解放送入墓地，作为仪式召唤的素材。
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		-- 中断当前效果处理，使之后的特殊召唤被视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 将选择的仪式怪兽以仪式召唤方式正面表示特殊召唤到自己的场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	else
		local lv=mc:GetLevel()
		-- 向玩家提示“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 设置附加检查函数，要求后续选择的素材组等级合计不超过lv（用于等级合计仪式召唤）。
		aux.GCheckAdditional=c51124303.RitualCheckAdditional(lv)
		local tg=sg:SelectSubGroup(tp,c51124303.RitualCheck,true,1,ft,lv)
		-- 选择完成后清除附加检查函数，避免影响后续其他选择。
		aux.GCheckAdditional=nil
		if not tg then goto cancel end
		local tc=tg:GetFirst()
		while tc do
			tc:SetMaterial(mat)
			tc=tg:GetNext()
		end
		if not mc:IsLocation(LOCATION_EXTRA) then
			-- 将选择的非额外卡组素材解放，作为仪式召唤多只怪兽的祭品。
			Duel.ReleaseRitualMaterial(mat)
		else
			-- 将选择的额外卡组素材代替解放送入墓地。
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		-- 中断当前效果处理，使后续特殊召唤与素材处理分开。
		Duel.BreakEffect()
		tc=tg:GetFirst()
		while tc do
			-- 以仪式召唤方式分步特殊召唤1只仪式怪兽，正面表示，用于处理多只怪兽同时特殊召唤。
			Duel.SpecialSummonStep(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
			tc=tg:GetNext()
		end
		-- 结束多只怪兽的分步特殊召唤，完成整个特殊召唤处理。
		Duel.SpecialSummonComplete()
	end
end
-- 效果②的发动条件：自己场上没有怪兽存在。
function c51124303.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（主怪兽区）怪兽数量是否为0。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 筛选可作为效果②代价除外的「影灵衣」怪兽：必须是「影灵衣」怪兽且能作为代价除外。
function c51124303.cfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果②的代价检测：这张卡自身和墓地1只「影灵衣」怪兽都能作为代价除外。
function c51124303.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查墓地是否存在至少1只满足剔除条件的「影灵衣」怪兽。
		and Duel.IsExistingMatchingCard(c51124303.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1只「影灵衣」怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c51124303.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 将选择的怪兽与这张卡一起正面表示除外作为效果②的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 筛选可加入手卡的「影灵衣」魔法卡：必须是「影灵衣」魔法卡且能被加入手卡。
function c51124303.thfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果②的发动目标检查：卡组中存在符合条件的「影灵衣」魔法卡，并设置操作信息为从卡组加入手卡。
function c51124303.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时确认卡组中是否存在可检索的「影灵衣」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c51124303.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果操作信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的发动处理：从卡组选1张「影灵衣」魔法卡加入手卡，并展示给对方玩家。
function c51124303.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「影灵衣」魔法卡。
	local g=Duel.SelectMatchingCard(tp,c51124303.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者的手卡，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
