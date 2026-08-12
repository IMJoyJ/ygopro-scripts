--SRブロックンロール
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡作为同调素材送去墓地的场合才能发动。把持有和用这张卡为同调素材的同调怪兽的原本等级相同等级的1只「疾行机人衍生物」（机械族·风·攻/守0）在自己场上特殊召唤。
function c69550259.initial_effect(c)
	-- ①：这张卡作为同调素材送去墓地的场合才能发动。把持有和用这张卡为同调素材的同调怪兽的原本等级相同等级的1只「疾行机人衍生物」（机械族·风·攻/守0）在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69550259,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,69550259)
	e1:SetCondition(c69550259.spcon)
	e1:SetTarget(c69550259.sptg)
	e1:SetOperation(c69550259.spop)
	c:RegisterEffect(e1)
	-- 建立素材卡与触发效果的关联，以便后续获取本次同调召唤出的怪兽
	aux.CreateMaterialReasonCardRelation(c,e1)
end
-- 判定是否作为同调素材送去墓地
function c69550259.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 效果发动的目标与可行性检测：获取同调怪兽及其原本等级，并确认其在场且自身场上有空位、可特招衍生物
function c69550259.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	local lv=rc:GetOriginalLevel()
	if chk==0 then return rc:IsRelateToEffect(e) and rc:IsFaceup()
		-- 检查自己场上是否有可用的怪兽区域空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能够特殊召唤符合该衍生物各项数值的怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,69550260,0x2016,TYPES_TOKEN_MONSTER,0,0,lv,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 将本次同调召唤出的怪兽设为效果处理的对象
	Duel.SetTargetCard(rc)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置产生衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- 效果处理：在自己场上特殊召唤1只与作为同调素材的同调怪兽原本等级相同的「疾行机人衍生物」
function c69550259.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为同调素材召唤出的同调怪兽
	local rc=Duel.GetFirstTarget()
	if not rc:IsRelateToChain() or rc:IsFacedown() then return end
	local lv=rc:GetOriginalLevel()
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 确认玩家是否可以特殊召唤该衍生物
	if Duel.IsPlayerCanSpecialSummonMonster(tp,69550260,0x2016,TYPES_TOKEN_MONSTER,0,0,lv,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建「疾行机人衍生物」的卡片数据
		local token=Duel.CreateToken(tp,69550260)
		-- 持有和用这张卡为同调素材的同调怪兽的原本等级相同等级
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		token:RegisterEffect(e1)
		-- 将衍生物以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
