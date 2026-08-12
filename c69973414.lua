--BF－ツインシャドウ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。自己场上有「黑羽」怪兽2只以上存在的场合，这张卡的发动从手卡也能用。
-- ①：让自己的墓地·除外状态的「黑羽」调整1只和调整以外的「黑羽」怪兽1只回到卡组·额外卡组才能发动。把持有和那2只的等级合计相同等级的1只「黑羽」同调怪兽或「黑翼龙」当作同调召唤从额外卡组特殊召唤。
function c69973414.initial_effect(c)
	-- 注册卡片密码9012916（黑翼龙）到该卡的关联卡片列表中。
	aux.AddCodeList(c,9012916)
	-- ①：让自己的墓地·除外状态的「黑羽」调整1只和调整以外的「黑羽」怪兽1只回到卡组·额外卡组才能发动。把持有和那2只的等级合计相同等级的1只「黑羽」同调怪兽或「黑翼龙」当作同调召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,69973414+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c69973414.cost)
	e1:SetTarget(c69973414.target)
	e1:SetOperation(c69973414.operation)
	c:RegisterEffect(e1)
	-- 自己场上有「黑羽」怪兽2只以上存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69973414,0))  --"适用「黑羽-双影」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c69973414.handcon)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「黑羽」怪兽。
function c69973414.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end
-- 手卡发动条件：自己场上存在2只以上的「黑羽」怪兽。
function c69973414.handcon(e)
	-- 检查自己场上是否存在至少2只表侧表示的「黑羽」怪兽。
	return Duel.IsExistingMatchingCard(c69973414.confilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil)
end
-- 过滤条件：自己墓地或除外状态的、等级大于0且能回到卡组或额外卡组的「黑羽」怪兽。
function c69973414.tdfilter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:GetLevel()>0
		and c:IsAbleToDeckOrExtraAsCost()
		and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 检查选取的2张卡是否为1只调整和1只非调整，且额外卡组存在等级等于这2只怪兽等级合计的、可特殊召唤的「黑羽」同调怪兽或「黑翼龙」。
function c69973414.fselect(g,e,tp)
	-- 检查卡片组是否由1张调整怪兽和1张非调整怪兽组成。
	return aux.gffcheck(g,Card.IsType,TYPE_TUNER,aux.NOT(Card.IsType),TYPE_TUNER)
		-- 并且额外卡组存在至少1只满足特殊召唤条件、且等级等于这2张卡等级合计的怪兽。
		and Duel.IsExistingMatchingCard(c69973414.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g:GetSum(Card.GetLevel))
end
-- 过滤条件：额外卡组中等级等于指定数值，且可以当作同调召唤特殊召唤的「黑羽」同调怪兽或「黑翼龙」。
function c69973414.spfilter(c,e,tp,lv)
	return (c:IsSetCard(0x33) and c:IsType(TYPE_SYNCHRO) or c:IsCode(9012916)) and c:IsLevel(lv)
		-- 并且额外怪兽区域或有连接端指向的主怪兽区域有空位可以特殊召唤该额外怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
-- 效果发动的Cost：选择墓地·除外状态的1只「黑羽」调整和1只非调整回到卡组·额外卡组。
function c69973414.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 获取自己墓地及除外状态下所有满足条件的「黑羽」怪兽。
	local g=Duel.GetMatchingGroup(c69973414.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if chk==0 then
		return g:CheckSubGroup(c69973414.fselect,2,2,e,tp)
	end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,c69973414.fselect,false,2,2,e,tp)
	e:SetLabel(sg:GetSum(Card.GetLevel))
	-- 选中选取的卡片并向双方玩家展示。
	Duel.HintSelection(sg)
	-- 将选中的卡片作为Cost送回卡组并洗牌。
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 效果发动的Target：进行必须成为同调素材的检测，并设置特殊召唤的操作信息。
function c69973414.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查是否存在必须作为同调素材的限制（由于此效果不使用场上的素材，若有此类限制则无法发动）。
		return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
	end
	-- 设置当前连锁的操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从额外卡组选择1只等级等于返回卡组怪兽等级合计的「黑羽」同调怪兽或「黑翼龙」当作同调召唤特殊召唤。
function c69973414.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查是否存在必须作为同调素材的限制，若有则不处理效果。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	local lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择1只满足条件的怪兽。
	local tc=Duel.SelectMatchingCard(tp,c69973414.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv):GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 尝试将选中的怪兽以同调召唤的方式表侧表示特殊召唤，并判断是否特殊召唤成功。
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
