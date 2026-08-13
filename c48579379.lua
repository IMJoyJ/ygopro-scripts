--究極完全態・グレート・モス
-- 效果：
-- 这张卡不能通常召唤。把有「进化之茧」装备的状态用自己回合计算经过6回合以上的自己场上1只「飞蛾宝宝」解放的场合可以特殊召唤。
function c48579379.initial_effect(c)
	c:EnableReviveLimit()
	-- 把有「进化之茧」装备的状态用自己回合计算经过6回合以上的自己场上1只「飞蛾宝宝」解放的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c48579379.spcon)
	e2:SetTarget(c48579379.sptg)
	e2:SetOperation(c48579379.spop)
	c:RegisterEffect(e2)
end
-- 检查该卡是否为「进化之茧」且其回合计数器达到6以上，即装备后经过了自己回合计算的6回合以上。
function c48579379.eqfilter(c)
	return c:IsCode(40240595) and c:GetTurnCounter()>=6
end
-- 筛选可作为解放素材的「飞蛾宝宝」：必须是卡名「飞蛾宝宝」，装备有满足条件的「进化之茧」，解放后自己场上仍有怪兽区空位，并且該「飞蛾宝宝」是自己控制或表侧表示。
function c48579379.rfilter(c,tp)
	return c:IsCode(58192742) and c:GetEquipGroup():FilterCount(c48579379.eqfilter,nil)>0
		-- 额外确认解放该「飞蛾宝宝」后自己场上存在可用的怪兽区，且该怪兽是自己控制或是表侧表示（避免选择无法解放或不可控的里侧怪兽）。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则效果的发动条件：若被检查的卡为nil则条件成立；否则检查自己场上是否存在至少1只满足解放素材条件的「飞蛾宝宝」。
function c48579379.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上·手卡是否存在至少1只满足rfilter条件且可以解放的「飞蛾宝宝」，用于特殊召唤。
	return Duel.CheckReleaseGroupEx(tp,c48579379.rfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤处理的选择阶段：从可解放的候选「飞蛾宝宝」中让玩家选择1张，选中后存入效果LabelObject并返回true；若未选择则返回false。
function c48579379.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上可解放的卡片组，并筛选出满足rfilter（即符合条件的「飞蛾宝宝」）的解放候选集合。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c48579379.rfilter,nil,tp)
	-- 向当前玩家显示选择提示，提示文字为“请选择要解放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤的实际处理：取得之前选择的「飞蛾宝宝」并将其解放，完成特殊召唤手续。
function c48579379.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的「飞蛾宝宝」作为特殊召唤代价解放。
	Duel.Release(g,REASON_SPSUMMON)
end
