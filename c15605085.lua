--ソーラー・ジェネクス
-- 效果：
-- 这张卡可以把1只「次世代」怪兽解放表侧表示上级召唤。
-- ①：这张卡在怪兽区域存在的状态，每次自己场上的表侧表示的「次世代」怪兽被送去墓地发动。给与对方500伤害。
function c15605085.initial_effect(c)
	-- 这张卡可以把1只「次世代」怪兽解放表侧表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15605085,0))  --"用1只名字带有「次世代」的怪兽解放召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c15605085.otcon)
	e1:SetOperation(c15605085.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- ①：这张卡在怪兽区域存在的状态，每次自己场上的表侧表示的「次世代」怪兽被送去墓地发动。给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15605085,1))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c15605085.damcon)
	e2:SetTarget(c15605085.damtg)
	e2:SetOperation(c15605085.damop)
	c:RegisterEffect(e2)
end
-- 筛选可作祭品的「次世代」怪兽：属于己方控制的卡，或表侧表示的卡（涵盖双方场上符合条件的候选）。
function c15605085.otfilter(c,tp)
	return c:IsSetCard(0x2) and (c:IsControler(tp) or c:IsFaceup())
end
-- 召唤规则效果的发动条件：若c为空则视为可发动；否则取得召唤者tp，检索候选祭品组，并判定该卡等级不低于7、所需解放数不超过1且场上存在合法的1只祭品。
function c15605085.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 以tp视角获取双方怪兽区域中满足otfilter（「次世代」且为己方控制或表侧表示）的怪兽，作为祭品候选组。
	local mg=Duel.GetMatchingGroup(c15605085.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判定上级召唤成立的条件：c的等级在7以上，要求的最少祭品数不超过1，且候选祭品组中存在可用作1只祭品的怪兽。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 召唤规则效果的操作：重新获取祭品候选组，选择1只祭品，将所选祭品设置为该卡的素材，并以召唤和素材的理由解放它们。
function c15605085.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 在处理召唤操作时，再次获取双方怪兽区域中满足otfilter的「次世代」怪兽，作为祭品候选组。
	local mg=Duel.GetMatchingGroup(c15605085.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家tp为这张卡从候选组中选择1只祭品，返回所选祭品的组sg。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 以召唤（REASON_SUMMON）和作为素材（REASON_MATERIAL）的理由解放所选祭品。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 判定某张卡是否为“自己场上被送去墓地表侧表示「次世代」怪兽”：满足「次世代」字段、之前控制者为tp、之前位于怪兽区域且为表侧表示。
function c15605085.cfilter(c,tp)
	return c:IsSetCard(0x2) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 伤害效果的发动条件：本次送去墓地的卡组eg中至少存在1只满足cfilter（自己场上表侧表示的「次世代」怪兽）的卡。
function c15605085.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15605085.cfilter,1,nil,tp)
end
-- 伤害效果的目标设置：效果处理时确定对方为对象，伤害值为500，并登记操作信息为造成500点伤害。
function c15605085.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把当前连锁的对象玩家设置为对方（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 把当前连锁的对象参数设置为500，作为伤害数值。
	Duel.SetTargetParam(500)
	-- 登记操作信息：将对1-tp玩家造成500点伤害（分类为CATEGORY_DAMAGE）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 伤害效果的处理：从连锁信息中获取目标玩家和伤害值，实际给对方造成效果伤害。
function c15605085.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家p和目标参数d（即设置了对象玩家为对方、参数为500）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果（REASON_EFFECT）为理由对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
