--真紅眼の闇竜
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的1只「真红眼黑龙」解放的场合才能特殊召唤。这张卡的攻击力，自己墓地存在的龙族怪兽每有1只上升300。
function c96561011.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上存在的1只「真红眼黑龙」解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c96561011.spcon)
	e2:SetTarget(c96561011.sptg)
	e2:SetOperation(c96561011.spop)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力，自己墓地存在的龙族怪兽每有1只上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c96561011.val)
	c:RegisterEffect(e3)
end
-- 计算自身攻击力上升数值的辅助函数
function c96561011.val(e,c)
	-- 获取自己墓地龙族怪兽的数量并乘以300，作为攻击力上升值
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,nil,RACE_DRAGON)*300
end
-- 过滤可作为特殊召唤解放媒介的「真红眼黑龙」的过滤函数
function c96561011.rfilter(c,tp)
	return c:IsCode(74677422)
		-- 检查该卡解放后是否能空出可用的怪兽区域，且该卡必须由自己控制或是场上表侧表示的卡
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件检查函数
function c96561011.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在至少1只满足过滤条件的可解放怪兽
	return Duel.CheckReleaseGroupEx(tp,c96561011.rfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的目标选择函数，用于选择要解放的怪兽
function c96561011.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可解放的卡片组，并过滤出符合条件的「真红眼黑龙」
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c96561011.rfilter,nil,tp)
	-- 给玩家发送提示信息，提示选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作函数
function c96561011.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选定的怪兽以进行特殊召唤
	Duel.Release(g,REASON_SPSUMMON)
end
