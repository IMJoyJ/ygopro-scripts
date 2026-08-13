--クリック＆エコー
-- 效果：
-- 这张卡不能作为融合·同调·超量召唤的素材。这个卡名的②的效果1回合可以使用最多2次。
-- ①：只要这张卡在怪兽区域存在，这张卡不能解放。
-- ②：这张卡作为连接素材送去墓地的场合发动。这张卡在从那个连接召唤的玩家来看的对方场上守备表示特殊召唤。
-- ③：只要这张卡的②的效果特殊召唤的这张卡在怪兽区域存在，自己把手卡持续公开。
local s,id,o=GetID()
-- 初始化函数：为这张卡依次注册所有效果，包括不能作为融合/同调/超量素材、不能解放、作为连接素材时特殊召唤以及公开手牌。
function s.initial_effect(c)
	-- 对应效果原文『这张卡不能作为融合·同调·超量召唤的素材。』中不能作为融合素材的部分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.mlimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e3)
	-- 对应效果原文『①：只要这张卡在怪兽区域存在，这张卡不能解放。』中不能作为上级召唤祭品的部分。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UNRELEASABLE_SUM)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e5)
	-- 对应效果原文『②：这张卡作为连接素材送去墓地的场合发动。这张卡在从那个连接召唤的玩家来看的对方场上守备表示特殊召唤。』
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_BE_MATERIAL)
	e6:SetCountLimit(2,id)
	e6:SetCondition(s.spcon)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
	-- 对应效果原文『③：只要这张卡的②的效果特殊召唤的这张卡在怪兽区域存在，自己把手卡持续公开。』
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))  --"自己把手卡持续公开"
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_PUBLIC)
	e7:SetRange(LOCATION_MZONE)
	e7:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e7:SetTargetRange(LOCATION_HAND,0)
	e7:SetCondition(s.rvcon)
	c:RegisterEffect(e7)
end
-- mlimit判断：当素材请求类型为融合召唤时返回true，使此卡不能作为融合素材。
function s.mlimit(e,c,st)
	return st==SUMMON_TYPE_FUSION
end
-- ②效果的发动条件：此卡因作为连接素材而进入墓地（r为REASON_LINK且自身位于墓地）时满足，可以发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- ②效果的目标检测：效果发动合法性检查通过时返回true，并准备将自身特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将自身登记为特殊召唤对象，数量1，不指定玩家与位置，供其他卡效果参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的实际处理：获取这次连接召唤的玩家，并将此卡在对方场上表侧守备表示特殊召唤；成功后给此卡打上标志，用于③效果的判定。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=c:GetReasonCard():GetSummonPlayer()
	if c:IsRelateToChain()
		-- 执行特殊召唤：由效果发动者将这张卡特殊召唤到连接召唤玩家的对方场上（表侧守备，不检查召唤条件与苏生限制），成功时继续执行后续处理。
		and Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,1-p,false,false,POS_FACEUP_DEFENSE)>0 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_WITHOUT_TEMP_REMOVE,0,1)
	end
end
-- ③效果的持续条件：仅当此卡是以②效果的方式进行特殊召唤（SUMMON_VALUE_SELF）且带有②效果标志时，才使自己的手牌持续公开。
function s.rvcon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_VALUE_SELF) and c:GetFlagEffect(id)>0
end
