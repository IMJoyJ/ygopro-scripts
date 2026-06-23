--真紅眼の不死竜
-- 效果：
-- 这张卡可以把1只不死族怪兽解放攻击表示上级召唤。
-- ①：这张卡战斗破坏不死族怪兽送去墓地时才能发动。那只不死族怪兽在自己场上特殊召唤。
function c5186893.initial_effect(c)
	-- ①：这张卡战斗破坏不死族怪兽送去墓地时才能发动。那只不死族怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5186893,0))  --"用1只不死族怪兽解放召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c5186893.otcon)
	e1:SetOperation(c5186893.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡可以把1只不死族怪兽解放攻击表示上级召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5186893,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(c5186893.spcon)
	e2:SetTarget(c5186893.sptg)
	e2:SetOperation(c5186893.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，返回满足条件的不死族怪兽（控制者或正面表示）
function c5186893.otfilter(c,tp)
	return c:IsRace(RACE_ZOMBIE) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足上级召唤条件：等级不低于7、最少祭品数不超过1、场上存在符合条件的祭品
function c5186893.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足条件的祭品组（不死族怪兽，控制者或正面表示）
	local mg=Duel.GetMatchingGroup(c5186893.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 返回等级不低于7且能进行1个祭品的通常召唤
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤时选择并解放祭品，设置素材并释放
function c5186893.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取满足条件的祭品组（不死族怪兽，控制者或正面表示）
	local mg=Duel.GetMatchingGroup(c5186893.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 从场上选择1个祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 以召唤和素材原因解放祭品
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 判断是否满足特殊召唤条件：战斗中破坏的怪兽在墓地且为不死族
function c5186893.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此次战斗中的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 若自身为攻击怪兽，则获取防守怪兽
	if c==tc then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	if not c:IsRelateToBattle() or c:IsFacedown() then return false end
	return tc:IsLocation(LOCATION_GRAVE) and tc:IsRace(RACE_ZOMBIE)
end
-- 设置特殊召唤目标并检查是否可以特殊召唤
function c5186893.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	-- 检查场上是否有空位可进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	tc:CreateEffectRelation(e)
	-- 设置操作信息，确定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 执行特殊召唤操作：将目标不死族怪兽特殊召唤到场上
function c5186893.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_ZOMBIE) then
		-- 以0方式、正面表示将目标怪兽特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
