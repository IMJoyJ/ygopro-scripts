--グレート・モス
-- 效果：
-- 装备了「进化之茧」的「飞蛾宝宝」4回合后（用自己的回合来数）作祭品来特殊召唤。
function c14141448.initial_effect(c)
	c:EnableReviveLimit()
	-- 将特殊召唤规则效果注册给此卡
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
-- 筛选装备了「进化之茧」且已使用4回合的「飞蛾宝宝」
function c14141448.eqfilter(c)
	return c:IsCode(40240595) and c:GetTurnCounter()>=4
end
-- 筛选满足条件的可解放卡片（装备了「进化之茧」且已使用4回合的「飞蛾宝宝」）
function c14141448.rfilter(c,tp)
	return c:IsCode(58192742) and c:GetEquipGroup():IsExists(c14141448.eqfilter,1,nil)
		-- 检查场上是否有可用怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 判断是否满足特殊召唤条件
function c14141448.spcon(e,c)
	if c==nil then return true end
	-- 检查场上是否存在满足条件的可解放卡片
	return Duel.CheckReleaseGroupEx(c:GetControler(),c14141448.rfilter,1,REASON_SPSUMMON,false,nil,c:GetControler())
end
-- 设置特殊召唤的目标选择函数
function c14141448.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 筛选满足条件的可解放卡片组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c14141448.rfilter,nil,tp)
	-- 向玩家发送选择解放卡片的提示消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 设置特殊召唤的处理函数
function c14141448.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标卡片以特殊召唤理由进行解放
	Duel.Release(g,REASON_SPSUMMON)
end
