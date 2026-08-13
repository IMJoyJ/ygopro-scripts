--グレート・モス
-- 效果：
-- 装备了「进化之茧」的「飞蛾宝宝」4回合后（用自己的回合来数）作祭品来特殊召唤。
function c14141448.initial_effect(c)
	c:EnableReviveLimit()
	-- 装备了「进化之茧」的「飞蛾宝宝」4回合后（用自己的回合来数）作祭品来特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c14141448.spcon)
	e2:SetTarget(c14141448.sptg)
	e2:SetOperation(c14141448.spop)
	c:RegisterEffect(e2)
end
-- 筛选符合条件的「进化之茧」：其卡号为40240595，且其回合计数器达到4以上（表示已装备/过去了4个自己的回合）。
function c14141448.eqfilter(c)
	return c:IsCode(40240595) and c:GetTurnCounter()>=4
end
-- 筛选符合条件的解放素材「飞蛾宝宝」：卡号为58192742，其装备区存在满足eqfilter条件的「进化之茧」，并且解放该素材后控制者场上仍有空位可供特殊召唤。
function c14141448.rfilter(c,tp)
	return c:IsCode(58192742) and c:GetEquipGroup():IsExists(c14141448.eqfilter,1,nil)
		-- 确认将该「飞蛾宝宝」解放后，其控制者场上还有空的怪兽区，用于特殊召唤「大飞蛾」。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则效果的条件判断：若检查的卡c为空则允许规则询问；否则检查控制者场上是否存在满足rfilter的可解放素材。
function c14141448.spcon(e,c)
	if c==nil then return true end
	-- 检查控制者场上是否存在至少1张满足rfilter条件的可解放卡（即装备了4回合以上「进化之茧」的「飞蛾宝宝」），且解放后有可用怪兽区。
	return Duel.CheckReleaseGroupEx(c:GetControler(),c14141448.rfilter,1,REASON_SPSUMMON,false,nil,c:GetControler())
end
-- 特殊召唤手续的选择目标操作：从可解放的卡组中筛选出符合条件的「飞蛾宝宝」，提示玩家选择要解放的卡；若选择成功则保存该卡到效果标签并返回true，否则返回false。
function c14141448.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家可解放的卡片组（不包含手卡），并从中筛选出满足rfilter条件的解放素材。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c14141448.rfilter,nil,tp)
	-- 向玩家显示“请选择要解放的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤处理时，从效果标签取出之前选择的解放素材卡，并将其解放。
function c14141448.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的「飞蛾宝宝」作为特殊召唤手续的祭品解放。
	Duel.Release(g,REASON_SPSUMMON)
end
