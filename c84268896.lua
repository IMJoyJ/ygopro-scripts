--アーティファクト－カドケウス
-- 效果：
-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。此外，只要这张卡在自己场上表侧表示存在，对方回合中名字带有「古遗物」的怪兽特殊召唤时，从卡组抽1张卡。「古遗物-商神杖」在自己场上只能有1只表侧表示存在。
function c84268896.initial_effect(c)
	c:SetUniqueOnField(1,0,84268896)
	-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- 魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84268896,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c84268896.spcon)
	e2:SetTarget(c84268896.sptg)
	e2:SetOperation(c84268896.spop)
	c:RegisterEffect(e2)
	-- 此外，只要这张卡在自己场上表侧表示存在，对方回合中名字带有「古遗物」的怪兽特殊召唤时，从卡组抽1张卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84268896,1))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c84268896.drcon)
	e3:SetTarget(c84268896.drtg)
	e3:SetOperation(c84268896.drop)
	c:RegisterEffect(e3)
end
-- 定义特殊召唤效果的发动条件判定函数
function c84268896.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 判定送去墓地的原因是否为被破坏，且当前是否为对方回合
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 定义特殊召唤效果的发动准备（Target）函数
function c84268896.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的操作信息，指定自身为特殊召唤对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义特殊召唤效果的执行（Operation）函数
function c84268896.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤出表侧表示且名字带有「古遗物」的怪兽
function c84268896.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x97)
end
-- 定义抽卡效果的发动条件判定函数
function c84268896.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合，且特殊召唤的怪兽中不包含自身，并存在至少一只表侧表示的「古遗物」怪兽
	return Duel.GetTurnPlayer()~=tp and not eg:IsContains(e:GetHandler()) and eg:IsExists(c84268896.filter,1,nil)
end
-- 定义抽卡效果的发动准备（Target）函数
function c84268896.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置抽卡效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的参数为1张卡
	Duel.SetTargetParam(1)
	-- 设置抽卡的操作信息，指定自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义抽卡效果的执行（Operation）函数
function c84268896.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 获取当前连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
