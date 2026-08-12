--サイバー・チュチュボン
-- 效果：
-- ①：这张卡可以从自己的手卡·场上把1只战士族或者天使族怪兽解放从手卡特殊召唤。
-- ②：这张卡为仪式召唤而被解放的场合，以自己墓地1张仪式魔法卡为对象才能发动。那张卡加入手卡。
function c42600274.initial_effect(c)
	-- ①：这张卡可以从自己的手卡·场上把1只战士族或者天使族怪兽解放从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c42600274.hspcon)
	e1:SetTarget(c42600274.hsptg)
	e1:SetOperation(c42600274.hspop)
	c:RegisterEffect(e1)
	-- ②：这张卡为仪式召唤而被解放的场合，以自己墓地1张仪式魔法卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCondition(c42600274.thcon)
	e2:SetTarget(c42600274.thtg)
	e2:SetOperation(c42600274.thop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的怪兽：战士族或天使族、控制者为指定玩家、场上存在可用怪兽区域
function c42600274.hspfilter(c,tp)
	-- 战士族或天使族、控制者为指定玩家、场上存在可用怪兽区域
	return c:IsRace(RACE_WARRIOR+RACE_FAIRY) and c:IsControler(tp) and Duel.GetMZoneCount(tp,c)>0
end
-- 判断特殊召唤条件是否满足：检查是否有满足条件的怪兽可被解放
function c42600274.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否有满足条件的怪兽可被解放
	return Duel.CheckReleaseGroupEx(tp,c42600274.hspfilter,1,REASON_SPSUMMON,true,e:GetHandler(),tp)
end
-- 设置特殊召唤时的选择目标：获取可解放的怪兽组并提示选择
function c42600274.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取可解放的怪兽组并筛选满足条件的怪兽
	local g=Duel.GetReleaseGroup(tp,true,REASON_SPSUMMON):Filter(c42600274.hspfilter,c,tp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤时的处理：解放选择的怪兽并标记出场方式
function c42600274.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标怪兽以特殊召唤原因进行解放
	Duel.Release(g,REASON_SPSUMMON)
	c:RegisterFlagEffect(0,RESET_EVENT+0x4fc0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(42600274,0))  --"出场方式为特殊召唤"
end
-- 判断是否为仪式召唤而被解放
function c42600274.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RITUAL)
end
-- 过滤满足条件的仪式魔法卡：类型为0x82（仪式魔法）且可加入手牌
function c42600274.thfilter(c)
	return c:GetType()==0x82 and c:IsAbleToHand()
end
-- 设置效果发动时的选择目标：选择墓地中的仪式魔法卡
function c42600274.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c42600274.thfilter(chkc) end
	-- 检查是否存在满足条件的仪式魔法卡
	if chk==0 then return Duel.IsExistingTarget(c42600274.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标仪式魔法卡
	local g=Duel.SelectTarget(tp,c42600274.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息：将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果处理：将目标卡加入手牌
function c42600274.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
