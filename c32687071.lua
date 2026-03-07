--アモルファージ・ノーテス
-- 效果：
-- ←3 【灵摆】 3→
-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
-- ①：只要自己场上有「无形噬体」怪兽存在，双方不能用抽卡以外的方法从卡组把卡加入手卡。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
function c32687071.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- ①：只要自己场上有「无形噬体」怪兽存在，双方不能用抽卡以外的方法从卡组把卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(c32687071.descon)
	e1:SetOperation(c32687071.desop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，双方不是「无形噬体」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c32687071.sumlimit)
	c:RegisterEffect(e2)
	-- 这张卡的控制者在每次自己准备阶段把自己场上1只怪兽解放。或者不解放让这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_HAND)
	e3:SetRange(LOCATION_PZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetCondition(c32687071.limcon)
	-- 设置效果目标为卡组中的卡
	e3:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	c:RegisterEffect(e3)
end
-- 判断是否为自己的准备阶段
function c32687071.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 处理准备阶段的解放或破坏选择
function c32687071.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选卡动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 检查是否有可解放的怪兽并询问是否解放
	if Duel.CheckReleaseGroupEx(tp,nil,1,REASON_MAINTENANCE,false,c) and Duel.SelectYesNo(tp,aux.Stringid(32687071,0)) then  --"是否解放自己场上1只怪兽？"
		-- 选择要解放的怪兽数量为1张
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_MAINTENANCE,false,c)
		-- 将选中的怪兽解放
		Duel.Release(g,REASON_MAINTENANCE)
	-- 若不选择解放则破坏此卡
	else Duel.Destroy(c,REASON_COST) end
end
-- 限制非无形噬体怪兽从额外卡组特殊召唤
function c32687071.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xe0)
end
-- 过滤函数：判断场上是否存在无形噬体怪兽
function c32687071.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe0)
end
-- 判断是否己方场上存在无形噬体怪兽
function c32687071.limcon(e)
	-- 检查己方场上是否存在无形噬体怪兽
	return Duel.IsExistingMatchingCard(c32687071.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
