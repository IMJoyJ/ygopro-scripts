--ソーラー・ジェネクス
-- 效果：
-- 这张卡可以把1只「次世代」怪兽解放表侧表示上级召唤。
-- ①：这张卡在怪兽区域存在的状态，每次自己场上的表侧表示的「次世代」怪兽被送去墓地发动。给与对方500伤害。
function c15605085.initial_effect(c)
	-- 效果原文：这张卡可以把1只「次世代」怪兽解放表侧表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15605085,0))  --"用1只名字带有「次世代」的怪兽解放召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c15605085.otcon)
	e1:SetOperation(c15605085.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 效果原文：①：这张卡在怪兽区域存在的状态，每次自己场上的表侧表示的「次世代」怪兽被送去墓地发动。给与对方500伤害。
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
-- 检索满足条件的「次世代」怪兽（包括自己控制且正面表示的怪兽）
function c15605085.otfilter(c,tp)
	return c:IsSetCard(0x2) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足上级召唤条件：怪兽等级不低于7，最少需要祭品数量为1，且场上存在满足条件的祭品
function c15605085.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上满足祭品条件的怪兽组
	local mg=Duel.GetMatchingGroup(c15605085.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 返回上级召唤条件是否满足
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行上级召唤操作：选择祭品并解放
function c15605085.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上满足祭品条件的怪兽组
	local mg=Duel.GetMatchingGroup(c15605085.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 从满足条件的怪兽中选择1个作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的祭品解放并用于上级召唤
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 检索满足条件的「次世代」怪兽（送入墓地前为己方控制且在主要怪兽区正面表示）
function c15605085.cfilter(c,tp)
	return c:IsSetCard(0x2) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 判断是否满足发动条件：是否有己方正面表示的「次世代」怪兽被送入墓地
function c15605085.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15605085.cfilter,1,nil,tp)
end
-- 设置伤害效果的目标玩家和伤害值
function c15605085.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的目标参数为500
	Duel.SetTargetParam(500)
	-- 设置连锁操作信息为造成500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 执行伤害效果：对目标玩家造成500点伤害
function c15605085.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害值
	Duel.Damage(p,d,REASON_EFFECT)
end
