--竜都アトランティス
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要场上有着有「龙都 亚特兰蒂斯」的卡名记述的怪兽存在，双方的手卡·场上的怪兽的等级下降1星。
-- ②：只要这张卡在场地区域存在，可以让自己把「泰达路斯」连接怪兽连接召唤的场合需要的连接素材数值减少1数值，连接素材的条件减少1只数量。
-- ③：这张卡在墓地存在，自己场上有「海」存在的场合才能发动。这张卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 初始化函数：登记卡名记述信息，注册场地卡发动用的空效果，并依次注册等级下降永续效果（e2）、连接素材减少的玩家效果（e3）和墓地自我放置的起动效果（e4）
function s.initial_effect(c)
	-- 在这张卡上登记卡名记述：自身「龙都 亚特兰蒂斯」（38391684）和「海」（22702055）
	aux.AddCodeList(c,38391684,22702055)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要场上有着有「龙都 亚特兰蒂斯」的卡名记述的怪兽存在，双方的手卡·场上的怪兽的等级下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,LOCATION_HAND+LOCATION_MZONE)
	e2:SetCondition(s.lvcon)
	e2:SetValue(-1)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在场地区域存在，可以让自己把「泰达路斯」连接怪兽连接召唤的场合需要的连接素材数值减少1数值，连接素材的条件减少1只数量。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(id)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,0)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡在墓地存在，自己场上有「海」存在的场合才能发动。这张卡在自己场上表侧表示放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"放置"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.ftcon)
	e4:SetTarget(s.fttg)
	e4:SetOperation(s.ftop)
	c:RegisterEffect(e4)
end
-- 等级下降效果的适用对象过滤函数：筛选场上表侧表示且卡名记述有「龙都 亚特兰蒂斯」的怪兽
function s.lvfilter(c)
	-- 条件是怪兽表侧表示存在且效果文本上记载着「龙都 亚特兰蒂斯」的卡名
	return c:IsFaceup() and aux.IsCodeListed(c,38391684)
end
-- 等级下降效果的适用条件函数：检查双方怪兽区域是否存在满足条件的怪兽
function s.lvcon(e)
	-- 检查双方怪兽区域是否至少存在1只表侧表示且卡名记述有「龙都 亚特兰蒂斯」的怪兽
	return Duel.IsExistingMatchingCard(s.lvfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤函数：筛选自己场上表侧表示的「海」（22702055）
function s.cfilter(c)
	return c:IsCode(22702055) and c:IsFaceup()
end
-- ③效果的发动条件函数：判断自己场上是否有「海」存在
function s.ftcon(e,tp,eg,ep,ev,re,r,rp)
	-- 自己场上存在表侧表示的「海」，或者当前生效的场地卡（环境）是「海」
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) or Duel.IsEnvironment(22702055,tp)
end
-- ③效果的目标函数：确认这张卡没有被禁止放置，且自己场上不存在同名场地卡（场地卡唯一性检查）
function s.fttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsForbidden() and e:GetHandler():CheckUniqueOnField(tp) end
end
-- ③效果的处理：确认这张卡仍与连锁关联且不受王家长眠之谷影响后，把自己场地区域原有的卡按规则送去墓地，再把这张卡在场地区域表侧表示放置
function s.ftop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与当前连锁关联，并且不受王家长眠之谷的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 获取自己场地区域（魔陷区5号位）当前存在的卡
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			-- 把场地区域原有的卡以规则原因送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使送去墓地与后续的放置不作为同时处理
			Duel.BreakEffect()
		end
		-- 把这张卡在自己场上的场地区域以表侧表示放置，并立即适用其效果
		Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
