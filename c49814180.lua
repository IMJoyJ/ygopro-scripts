--マスターモンク
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的1只「武僧战士」做祭品的场合才能特殊召唤。这张卡1回合可以攻击2次。
function c49814180.initial_effect(c)
	c:EnableReviveLimit()
	-- “这张卡不能通常召唤。把自己场上存在的1只「武僧战士」做祭品的场合才能特殊召唤。”——注册一个不可无效、不可复制的特殊召唤条件，限制本卡只能通过规则效果特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- “把自己场上存在的1只「武僧战士」做祭品的场合才能特殊召唤。”——以场地型效果注册手牌中的该卡的特殊召唤手续，并指定条件/目标/处理函数。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c49814180.spcon)
	e2:SetTarget(c49814180.sptg)
	e2:SetOperation(c49814180.spop)
	c:RegisterEffect(e2)
	-- “这张卡1回合可以攻击2次。”——通过EFFECT_EXTRA_ATTACK设定额外攻击次数为1，使该卡1回合可攻击2次。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 筛选可作为解放素材的「武僧战士」：卡名正确，且解放该卡后tp方怪兽区仍有空位可供特殊召唤，同时该卡满足可解放条件（由tp方控制或表侧表示）。
function c49814180.spfilter(c,tp)
	return c:IsCode(3810071)
		-- 判断解放该候选卡后tp方怪兽区仍有空余位置，并且该候选卡由tp控制或为表侧表示，以保证其可作为解放素材。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件部分：若c为空则允许（规则询问）；否则检查tp方能否从可解放怪兽中选出1只满足spfilter的「武僧战士」作为祭品。
function c49814180.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 调用全局检查，确认tp方是否存在至少1只满足spfilter条件的卡可作为本次特殊召唤的解放素材。
	return Duel.CheckReleaseGroupEx(tp,c49814180.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的选择处理：从可解放怪兽中筛选出符合条件的「武僧战士」，要求玩家选出1张；选中后将其存入LabelObject并返回成功，否则返回失败。
function c49814180.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取tp方可解放的怪兽组（不含手卡），再用spfilter过滤出可作为本次祭品的「武僧战士」供玩家选择。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c49814180.spfilter,nil,tp)
	-- 向tp方显示选择提示，要求其选择1张要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的实际执行处理：从LabelObject取出之前选择的祭品卡并将其解放，完成特殊召唤手续。
function c49814180.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的「武僧战士」以REASON_SPSUMMON（作为特殊召唤手续的原因）解放。
	Duel.Release(g,REASON_SPSUMMON)
end
