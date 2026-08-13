--メタル・デビルゾア
-- 效果：
-- 这张卡不能通常召唤。把有「金属化·魔法反射装甲」装备的自己场上1只「恶魔兽灵」解放的场合可以从卡组特殊召唤。
function c50705071.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把有「金属化·魔法反射装甲」装备的自己场上1只「恶魔兽灵」解放的场合可以从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCondition(c50705071.spcon)
	e1:SetTarget(c50705071.sptg)
	e1:SetOperation(c50705071.spop)
	c:RegisterEffect(e1)
end
-- 特殊召唤的解放素材过滤函数：候选卡必须是「恶魔兽灵」（24311372），且装备有「金属化·魔法反射装甲」（68540058），并且解放后仍留有可用的怪兽区域用于特殊召唤。
function c50705071.spfilter(c,tp)
	return c:IsCode(24311372) and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,68540058)
		-- 确认将这张「恶魔兽灵」解放后，玩家tp场上还有空余的怪兽区域，确保要特殊召唤的卡有位置可放。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤的发动条件判定：当正被检查的卡c为nil时视为可用（供规则搜索），否则检查当前玩家tp场上·手卡是否存在至少1只满足解放条件的「恶魔兽灵」。
function c50705071.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 调用Duel.CheckReleaseGroupEx检查当前玩家tp是否有至少1只可解放的、装备了「金属化·魔法反射装甲」的「恶魔兽灵」，并将其作为特殊召唤的代价。
	return Duel.CheckReleaseGroupEx(tp,c50705071.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤的发动时选择处理：筛选出所有符合条件的可解放「恶魔兽灵」，让玩家选择1只，选择成功则将该卡记录到效果e的LabelObject中并返回true，否则不发动。
function c50705071.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家tp可解放（非上级召唤）的卡组，并筛选出其中所有满足spfilter解放条件的候选「恶魔兽灵」。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c50705071.spfilter,nil,tp)
	-- 给玩家显示“请选择要解放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤的处理操作：从效果e中取出在sptg阶段选择的解放对象，解放该怪兽，然后洗切卡组，完成从卡组的特殊召唤。
function c50705071.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的「恶魔兽灵」解放，作为从卡组特殊召唤这张卡的代价。
	Duel.Release(g,REASON_SPSUMMON)
	-- 洗切玩家的卡组，因为这张卡是从卡组特殊召唤，需要将卡组重新随机排列。
	Duel.ShuffleDeck(tp)
end
