--ビーストアイズ・ペンデュラム・ドラゴン
-- 效果：
-- 龙族·暗属性怪兽＋兽族怪兽
-- 这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把自己场上的上记卡解放的场合可以从额外卡组特殊召唤（不需要「融合」）。
-- ①：这张卡战斗破坏怪兽的场合发动。给与对方作为这张卡的融合素材的1只兽族怪兽的原本攻击力数值的伤害。
function c72378329.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为满足条件的暗属性龙族怪兽和兽族怪兽各1只
	aux.AddFusionProcFun2(c,c72378329.ffilter,aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),true)
	-- 添加接触融合召唤手续，通过解放自己场上的融合素材怪兽从额外卡组特殊召唤
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	-- 这张卡用融合召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制特殊召唤条件，使其只能通过融合召唤（或其自身规则）来特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：这张卡战斗破坏怪兽的场合发动。给与对方作为这张卡的融合素材的1只兽族怪兽的原本攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置发动条件为这张卡战斗破坏怪兽
	e3:SetCondition(aux.bdcon)
	e3:SetTarget(c72378329.damtg)
	e3:SetOperation(c72378329.damop)
	c:RegisterEffect(e3)
	-- 作为这张卡的融合素材的1只兽族怪兽的原本攻击力数值
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c72378329.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 过滤融合素材中的暗属性龙族怪兽
function c72378329.ffilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionAttribute(ATTRIBUTE_DARK)
end
-- 伤害效果的发动准备，获取记录的伤害数值并设置给对方玩家造成伤害的操作信息
function c72378329.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetLabel()
	-- 设置效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为计算出的伤害数值
	Duel.SetTargetParam(dam)
	-- 设置连锁操作信息为给与对方玩家指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的执行，获取目标玩家和伤害数值并执行伤害处理
function c72378329.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 检查融合素材，筛选出兽族怪兽并获取其原本攻击力，将该数值记录在伤害效果中
function c72378329.valcheck(e,c)
	local g=c:GetMaterial():Filter(Card.IsRace,nil,RACE_BEAST)
	local atk=0
	if g:GetCount()>0 then
		atk=g:GetFirst():GetTextAttack()
		if atk<0 then atk=0 end
	end
	e:GetLabelObject():SetLabel(atk)
end
