--究極完全態・グレート・モス
-- 效果：
-- 这张卡不能通常召唤。把有「进化之茧」装备的状态用自己回合计算经过6回合以上的自己场上1只「飞蛾宝宝」解放的场合可以特殊召唤。
function c48579379.initial_effect(c)
	c:EnableReviveLimit()
	-- 创建一个字段效果，用于处理特殊召唤的条件、目标和操作
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
-- 过滤函数：检查装备卡是否为「进化之茧」且已过6回合
function c48579379.eqfilter(c)
	return c:IsCode(40240595) and c:GetTurnCounter()>=6
end
-- 过滤函数：检查场上是否有满足条件的「飞蛾宝宝」（装备有进化之茧且回合数≥6）
function c48579379.rfilter(c,tp)
	return c:IsCode(58192742) and c:GetEquipGroup():FilterCount(c48579379.eqfilter,nil)>0
		-- 确保该怪兽在场上的怪兽区域数量大于0，或其为表侧表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断特殊召唤条件是否满足：检查是否存在可解放的符合条件的怪兽
function c48579379.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 调用CheckReleaseGroupEx函数检测是否有满足rfilter条件的卡可被解放
	return Duel.CheckReleaseGroupEx(tp,c48579379.rfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 设置特殊召唤的目标选择逻辑：筛选符合条件的怪兽并提示玩家选择
function c48579379.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的卡片组，并从中筛选满足rfilter条件的卡片
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c48579379.rfilter,nil,tp)
	-- 向玩家发送提示信息，提示其选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义特殊召唤的操作函数：将选定的卡片进行解放处理
function c48579379.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 执行解放操作，将目标卡片以特殊召唤理由进行解放
	Duel.Release(g,REASON_SPSUMMON)
end
