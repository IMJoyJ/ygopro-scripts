--妖精霊クリボン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「古代妖精龙」或者兽族·植物族·天使族的光属性怪兽的其中任意种存在的场合才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡当作调整使用。
-- ②：自己场上的其他的「古代妖精龙」或者有那个卡名记述的怪兽被效果破坏的场合，可以作为代替让场上的这张卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个效果：①特殊召唤效果和②代替破坏效果
function s.initial_effect(c)
	-- 记录该卡效果文本中记载着「古代妖精龙」（卡号25862681）
	aux.AddCodeList(c,25862681)
	-- ①：自己场上有「古代妖精龙」或者兽族·植物族·天使族的光属性怪兽的其中任意种存在的场合才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的其他的「古代妖精龙」或者有那个卡名记述的怪兽被效果破坏的场合，可以作为代替让场上的这张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
-- 用于判断场上是否存在满足条件的怪兽（光属性+兽族/天使族/植物族，或为古代妖精龙）
function s.cfilter(c)
	return c:IsFaceupEx() and (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST+RACE_FAIRY+RACE_PLANT) and c:IsType(TYPE_MONSTER)
		or c:IsCode(25862681))
end
-- 判断是否满足特殊召唤的发动条件：自己场上有满足条件的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足条件的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 设置特殊召唤的发动目标，判断是否可以进行特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，若成功则将此卡当作调整使用
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否还在场上（未被破坏或送入墓地等）且是否可以特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 将此卡的效果类型设为单体效果，增加其类型为调整（TYPE_TUNER）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程，结束本次特殊召唤处理
	Duel.SpecialSummonComplete()
end
-- 用于判断是否为可代替破坏的怪兽（古代妖精龙或其效果记载的怪兽）
function s.repfilter(c)
	-- 判断该怪兽是否为古代妖精龙或其效果记载的怪兽
	return (c:IsCode(25862681) or aux.IsCodeListed(c,25862681) and c:IsType(TYPE_MONSTER))
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 设置代替破坏效果的发动目标，判断是否可以发动此效果
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and eg:IsExists(s.repfilter,1,nil,tp) and not eg:IsContains(c) end
	-- 向玩家询问是否发动此效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 返回代替破坏效果的判断结果
function s.repval(e,c)
	return s.repfilter(c)
end
-- 执行代替破坏效果的操作，将此卡送回手牌
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，显示此卡被发动
	Duel.Hint(HINT_CARD,0,id)
	-- 将此卡以效果原因送回手牌
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
