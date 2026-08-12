--キメラテック・オーバー・ドラゴン
-- 效果：
-- 「电子龙」＋机械族怪兽1只以上
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡融合召唤的场合发动。自己场上的其他卡全部送去墓地。
-- ②：这张卡的原本的攻击力·守备力变成作为这张卡的融合素材的怪兽数量×800。
-- ③：这张卡在同1次的战斗阶段中可以向怪兽作出最多有作为这张卡的融合素材的怪兽数量的攻击。
function c64599569.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为1只「电子龙」和1只以上的机械族怪兽
	aux.AddFusionProcCodeFunRep(c,70095154,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),1,127,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡只能通过融合召唤的方式特殊召唤
	e2:SetValue(aux.fuslimit)
	c:RegisterEffect(e2)
	-- ②：这张卡的原本的攻击力·守备力变成作为这张卡的融合素材的怪兽数量×800。③：这张卡在同1次的战斗阶段中可以向怪兽作出最多有作为这张卡的融合素材的怪兽数量的攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c64599569.sumcon)
	e3:SetOperation(c64599569.sucop)
	c:RegisterEffect(e3)
	-- ①：这张卡融合召唤的场合发动。自己场上的其他卡全部送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c64599569.sumcon)
	e4:SetOperation(c64599569.tgop)
	c:RegisterEffect(e4)
end
c64599569.material_setcode=0x1093
-- 用于检测融合素材中是否包含「电子龙」的辅助函数
function c64599569.cyber_fusion_check(tp,sg,fc)
	return sg:IsExists(Card.IsFusionCode,1,nil,70095154)
end
-- 判断该怪兽的特殊召唤方式是否为融合召唤
function c64599569.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 融合召唤成功时，根据融合素材数量确定原本攻击力、守备力以及对怪兽的追加攻击次数
function c64599569.sucop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：这张卡的原本的攻击力·守备力变成作为这张卡的融合素材的怪兽数量×800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(c:GetMaterialCount()*800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetValue(c:GetMaterialCount()-1)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
end
-- 融合召唤成功时的诱发效果，将自己场上除这张卡以外的其他卡全部送去墓地
function c64599569.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上除这张卡以外的所有卡片
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,aux.ExceptThisCard(e))
	-- 将获取到的卡片因效果全部送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
