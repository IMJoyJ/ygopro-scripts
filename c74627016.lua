--TG タンク・ラーヴァ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把自己场上的这张卡作为「科技属」同调怪兽的同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
-- ②：这张卡作为「科技属」同调怪兽的同调素材送去墓地的场合才能发动。在自己场上把1只「科技属衍生物」（机械族·地·1星·攻/守0）攻击表示特殊召唤。
function c74627016.initial_effect(c)
	-- ①：把自己场上的这张卡作为「科技属」同调怪兽的同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetValue(c74627016.tnval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡作为「科技属」同调怪兽的同调素材送去墓地的场合才能发动。在自己场上把1只「科技属衍生物」（机械族·地·1星·攻/守0）攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74627016,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,74627016)
	e2:SetCondition(c74627016.tkcon)
	e2:SetTarget(c74627016.tktg)
	e2:SetOperation(c74627016.tkop)
	c:RegisterEffect(e2)
end
-- 检查作为同调素材的这张卡是否由自身控制，且该同调怪兽是否为「科技属」怪兽
function c74627016.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler()) and c:IsSetCard(0x27)
end
-- 检查这张卡是否作为「科技属」同调怪兽的同调素材送去墓地
function c74627016.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and e:GetHandler():GetReasonCard():IsSetCard(0x27)
end
-- 特殊召唤衍生物效果的发动准备与合法性检查
function c74627016.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的「科技属衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,74627017,0x27,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) end
	-- 设置操作信息，表示该效果包含产生衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示该效果包含特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤衍生物效果的实际处理
function c74627016.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域空格，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 若玩家不能特殊召唤指定的「科技属衍生物」，则不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,74627017,0x27,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) then return end
	-- 创建卡号为74627017的「科技属衍生物」卡片
	local token=Duel.CreateToken(tp,74627017)
	-- 将创建的衍生物以表侧攻击表示特殊召唤到自己的场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
end
