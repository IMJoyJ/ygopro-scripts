--ラーバモス
-- 效果：
-- 这张卡不能通常召唤。需要装备了「进化之茧」2回合（数自己的回合数）的「飞蛾宝宝」做祭品特殊召唤上场。
function c87756343.initial_effect(c)
	c:EnableReviveLimit()
	-- 需要装备了「进化之茧」2回合（数自己的回合数）的「飞蛾宝宝」做祭品特殊召唤上场。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c87756343.spcon)
	e2:SetTarget(c87756343.sptg)
	e2:SetOperation(c87756343.spop)
	c:RegisterEffect(e2)
end
-- 过滤装备卡是「进化之茧」且回合计数器达到2个回合以上的卡片
function c87756343.eqfilter(c)
	return c:IsCode(40240595) and c:GetTurnCounter()>=2
end
-- 过滤作为解放祭品的「飞蛾宝宝」，要求其装备了满足条件的「进化之茧」，且解放后有可用的怪兽区域
function c87756343.rfilter(c,tp)
	return c:IsCode(58192742) and c:GetEquipGroup():FilterCount(c87756343.eqfilter,nil)>0
		-- 检查该卡解放后是否有可用的怪兽区域，且该卡必须是自己控制的卡或者是表侧表示的卡
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件判定，检查场上是否存在满足解放条件的「飞蛾宝宝」
function c87756343.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在至少1张满足解放过滤条件的卡片
	return Duel.CheckReleaseGroupEx(tp,c87756343.rfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的目标选择，让玩家选择1只满足解放条件的「飞蛾宝宝」作为祭品并记录
function c87756343.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可解放的卡片组，并筛选出满足解放条件的「飞蛾宝宝」
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c87756343.rfilter,nil,tp)
	-- 向玩家发送选择要解放的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作，解放选中的「飞蛾宝宝」
function c87756343.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为原因解放选中的卡片
	Duel.Release(g,REASON_SPSUMMON)
end
