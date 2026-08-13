--流星極輝巧群
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「龙辉巧」卡被除外的场合，把自己场上1只「龙辉巧」怪兽解放，以自己的除外状态的最多2张「龙辉巧」卡为对象才能发动。那些卡加入手卡。
-- ②：把手卡1张「流星辉巧群」给对方观看才能发动。攻击力合计直到变成仪式召唤的怪兽的攻击力以上为止，把自己的手卡·场上的机械族怪兽解放，从自己的手卡·墓地把1只机械族仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 注册该卡片作为魔法卡的发动效果，以及①和②两个效果；①②效果各自设定1回合1次、条件、代价、目标与处理。
function s.initial_effect(c)
	-- 将该卡记述的「流星辉巧群」（卡号22398665）加入代码列表，用于卡名关联与检索。
	aux.AddCodeList(c,22398665)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：「龙辉巧」卡被除外的场合，把自己场上1只「龙辉巧」怪兽解放，以自己的除外状态的最多2张「龙辉巧」卡为对象才能发动。那些卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收除外"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.thcon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：把手卡1张「流星辉巧群」给对方观看才能发动。攻击力合计直到变成仪式召唤的怪兽的攻击力以上为止，把自己的手卡·场上的机械族怪兽解放，从自己的手卡·墓地把1只机械族仪式怪兽仪式召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"墓地仪式"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 判定被除外的卡是否为表侧表示的「龙辉巧」系列卡，用于触发①效果。
function s.cfilter(c)
	return c:IsSetCard(0x154) and c:IsFaceupEx()
end
-- ①效果的触发条件：只要本次被除外的一组卡中存在至少1张表侧表示的「龙辉巧」卡即可发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
-- 作为①效果解放代价的过滤条件：必须是「龙辉巧」系列怪兽。
function s.rlfilter(c)
	return c:IsSetCard(0x154) and c:IsType(TYPE_MONSTER)
end
-- ①效果的代价：从自己场上选择1只「龙辉巧」怪兽解放；先确认是否存在可解放的素材，再选择并解放。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：检查自己场上是否存在至少1只可作为代价解放的「龙辉巧」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.rlfilter,1,nil) end
	-- 选择自己场上1只「龙辉巧」怪兽作为代价。
	local g=Duel.SelectReleaseGroup(tp,s.rlfilter,1,1,nil)
	-- 将选择的怪兽解放（REASON_COST，作为代价处理）。
	Duel.Release(g,REASON_COST)
end
-- 对象选择过滤：选择自己除外状态的表侧「龙辉巧」卡，且该卡能被加入手卡。
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x154) and c:IsAbleToHand()
end
-- ①效果取对象：从自己除外状态的表侧「龙辉巧」卡中选择1～2张作为对象，并设置回收手卡的操作信息；若为连锁确认对象则直接判定合法性。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 目标检测：确认自己的除外状态是否存在至少1张符合条件的「龙辉巧」卡。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己除外状态的符合条件的「龙辉巧」卡中选择1～2张作为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,2,nil)
	-- 设置操作信息：本次效果将把对象卡加入手卡（CATEGORY_TOHAND），数量为选择的对象数。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ①效果处理：取得连锁对象，过滤出仍与该效果关联的卡，将其加入持有者手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中选择的对象卡组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if rg:GetCount() then
		-- 将仍关联的对象卡送去持有者手卡（效果处理，实际加入手卡）。
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
	end
end
-- ②效果代价的过滤：手卡中的「流星辉巧群」（卡号22398665）且尚未公开。
function s.costfilter(c)
	return c:IsCode(22398665) and not c:IsPublic()
end
-- ②效果的代价：从手卡选择1张「流星辉巧群」给对方观看，然后洗切手卡；先确认是否存在可展示的卡。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认手卡中是否存在可展示的「流星辉巧群」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 显示“请选择给对方确认的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手卡中1张「流星辉巧群」作为展示代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的「流星辉巧群」给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切手卡，避免对方得知手卡顺序。
	Duel.ShuffleHand(tp)
end
-- 仪式素材过滤：必须是机械族怪兽。
function s.rfilter(c)
	return c:IsRace(RACE_MACHINE)
end
-- ②效果的目标选择：从手卡·墓地选择1只可用机械族素材仪式召唤的机械族仪式怪兽，并设置仪式召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前玩家可用的机械族仪式解放素材（手卡、场上等符合条件且不在限制中的卡）。
		local mg=Duel.GetRitualMaterialEx(tp):Filter(Card.IsRace,nil,RACE_MACHINE)
		-- 检查手卡·墓地是否存在至少1只机械族仪式怪兽，满足能用上述素材以攻击力合计以上的方式仪式召唤。
		return Duel.IsExistingMatchingCard(s.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,s.rfilter,e,tp,mg,nil,aux.GetCappedAttack,"Greater")
	end
	-- 设置操作信息：本次效果将进行仪式特殊召唤，对象范围为手卡·墓地的1只仪式怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果处理：选择要仪式召唤的怪兽，选择满足攻击力条件的机械族解放素材并解放，然后仪式召唤；若素材选择被取消则重新选择。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 处理时重新获取可用的机械族仪式解放素材，确保状态最新。
	local mg=Duel.GetRitualMaterialEx(tp):Filter(Card.IsRace,nil,RACE_MACHINE)
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手卡·墓地中1只符合条件的机械族仪式怪兽作为仪式召唤对象（使用王家长眠之谷过滤，墓地卡的可用性受其影响）。
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,s.rfilter,e,tp,mg,nil,aux.GetCappedAttack,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 显示“请选择要解放的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置额外的解放素材组合检查函数，用于在搜索素材组合时判定攻击力合计是否满足“大于等于仪式怪兽攻击力”的条件。
		aux.GCheckAdditional=s.RitualCheckAdditional(tc,tc:GetAttack(),"Greater")
		local mat=mg:SelectSubGroup(tp,s.RitualCheck,true,1,#mg,tp,tc,tc:GetAttack(),"Greater")
		-- 清除第38行设置的额外检查函数，避免影响后续其他效果。
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 将选择的素材作为仪式召唤的cost解放（墓地的仪式魔人等特殊素材按规则除外）。
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理，使仪式召唤成功后的时点独立处理，避免错过时点。
		Duel.BreakEffect()
		-- 将选择的仪式怪兽以仪式召唤方式表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 检查一组解放素材的攻击力合计是否大于等于仪式怪兽的攻击力（使用系统安全攻击力上限，攻击力为0时不合法）。
function s.RitualCheckGreater(g,c,atk)
	if atk==0 then return false end
	-- 将当前候选素材组标记为已选择卡片，供后续攻击力合计计算使用。
	Duel.SetSelectedCard(g)
	-- 判定该组素材的攻击力合计是否达到目标攻击力（>=）。
	return g:CheckWithSumGreater(aux.GetCappedAttack,atk)
end
-- 检查一组解放素材的攻击力合计是否恰好等于仪式怪兽的攻击力（本卡不使用Equal模式，但保留供通用）。
function s.RitualCheckEqual(g,c,atk)
	if atk==0 then return false end
	-- 判定该组素材的攻击力合计是否恰好等于目标攻击力，且素材数量等于当前组数量。
	return g:CheckWithSumEqual(aux.GetCappedAttack,atk,#g,#g)
end
-- 综合判定一组素材能否用于仪式召唤：满足攻击力条件（大于等于或等于）、解放后怪兽区有空位、满足仪式怪兽自身素材限制和全局额外限制。
function s.RitualCheck(g,tp,c,atk,greater_or_equal)
	-- 判定素材组满足攻击力条件（由具体Greater/Equal函数决定）且解放这些素材后自己场上仍有可用怪兽区域。
	return s["RitualCheck"..greater_or_equal](g,c,atk) and Duel.GetMZoneCount(tp,g,tp)>0 and (not c.mat_group_check or c.mat_group_check(g,tp))
		-- 判定素材组还满足其他全局额外的仪式召唤限制（如特定卡片效果附加的限制）。
		and (not aux.RCheckAdditional or aux.RCheckAdditional(tp,g,c))
end
-- 根据“Equal”或“Greater”模式生成解放素材组合的附加检查函数：Equal模式限制素材攻击力合计不超过目标攻击力；Greater模式限制除当前考虑卡外其余素材合计不超过目标攻击力，用于优化组合搜索。
function s.RitualCheckAdditional(c,atk,greater_or_equal)
	if greater_or_equal=="Equal" then
		return  function(g)
					-- Equal模式下的素材组判定：在满足其他全局限制的同时，素材攻击力合计不超过目标攻击力，确保等额祭品。
					return (not aux.RGCheckAdditional or aux.RGCheckAdditional(g)) and g:GetSum(aux.GetCappedAttack)<=atk
				end
	else
		return  function(g,ec)
					if atk==0 then return #g<=1 end
					if ec then
						-- Greater模式下带当前考虑卡片时的素材组判定：除ec外其余素材攻击力合计不超过目标攻击力，防止组合搜索越界。
						return (not aux.RGCheckAdditional or aux.RGCheckAdditional(g,ec)) and g:GetSum(aux.GetCappedAttack)-aux.GetCappedAttack(ec)<=atk
					else
						-- Greater模式下无当前考虑卡片时的素材组判定：仅需满足其他全局限制即可。
						return not aux.RGCheckAdditional or aux.RGCheckAdditional(g)
					end
				end
	end
end
-- 筛选可作为仪式召唤对象的仪式怪兽：必须是仪式怪兽（类型位0x81说明含仪式+怪兽）、通过额外过滤器、能够仪式召唤，且存在一组机械族素材可将其仪式召唤。
function s.RitualUltimateFilter(c,filter,e,tp,m1,m2,attack_function,greater_or_equal,chk)
	if bit.band(c:GetType(),0x81)~=0x81 or (filter and not filter(c,e,tp,chk)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if m2 then
		mg:Merge(m2)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	local atk=attack_function(c)
	-- 在筛选仪式怪兽时，设置全局附加的素材组合检查函数，用于判断是否存在合法素材组合。
	aux.GCheckAdditional=s.RitualCheckAdditional(c,atk,greater_or_equal)
	local res=mg:CheckSubGroup(s.RitualCheck,1,#mg,tp,c,atk,greater_or_equal)
	-- 筛选结束后清除全局附加检查函数，避免影响其他效果。
	aux.GCheckAdditional=nil
	return res
end
