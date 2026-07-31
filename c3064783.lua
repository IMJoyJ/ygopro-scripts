--シャイニング・アンブラル
local s,id,o=GetID()
-- 初始化卡片效果，创建并注册三个效果：召唤成功时特殊召唤+抽卡、特殊召唤成功时触发的相同效果、以及超量素材相关效果
function s.initial_effect(c)
	-- 当自己的怪兽通常召唤成功时，可以将此卡从手牌特殊召唤到场上，并且可以抽一张卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 此卡在场上的时候，可以作为超量怪兽的2只数量的素材
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DOUBLE_XMATERIAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.sxyzfilter)
	e3:SetValue(id)
	e3:SetCountLimit(1,id+o)
	c:RegisterEffect(e3)
end
-- 检查场上是否有己方正面表示的「光」或「影」属性超量怪兽
function s.cfilter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x87) or c:IsSetCard(0x1e3) and c:IsType(TYPE_XYZ)) and c:IsSummonPlayer(tp)
end
-- 判断是否满足特殊召唤条件：己方有符合条件的怪兽被召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 设置效果处理时的条件判断，包括玩家可以抽卡、场上存在空位、此卡可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查场上是否有足够的怪兽区域以及此卡是否可以特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将此卡特殊召唤到场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：让玩家抽一张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行效果处理，先将此卡特殊召唤到场上，然后进行抽卡，若抽到的卡是「光」属性则可再特殊召唤该卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否还在连锁中且成功特殊召唤到场上
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 让玩家抽一张卡，若无法抽卡则效果结束
		if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
		-- 获取本次抽卡操作实际抽到的卡片
		local dc=Duel.GetOperatedGroup():GetFirst()
		if dc:IsSetCard(0x87) and dc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检查抽到的卡是否为「光」属性、可再次特殊召唤、场上存在空位并询问玩家是否发动额外效果
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			-- 中断当前效果处理，使后续效果视为错时点处理
			Duel.BreakEffect()
			-- 将抽到的卡以特殊召唤方式加入场上
			Duel.SpecialSummon(dc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 设定超量素材过滤条件：只有「影」属性的怪兽可作为此卡的超量素材
function s.sxyzfilter(e,c)
	return c:IsSetCard(0x48)
end
