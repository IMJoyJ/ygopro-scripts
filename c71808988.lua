--ブルーアイズ・トゥーン・アルティメットドラゴン
local s,id,o=GetID()
-- 注册卡片效果的入口函数，定义并注册此卡的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册素材信息，此卡关联「卡通青眼白龙」
	aux.AddMaterialCodeList(c,53183600)
	-- 注册素材系列信息，此卡关联「卡通」系列
	aux.AddSetNameMonsterList(c,0x62)
	-- 注册融合素材判定：必须以「卡通青眼白龙」＋卡通怪兽2只为素材
	aux.AddFusionProcFunFun(c,aux.FilterBoolFunction(Card.IsFusionCode,53183600),s.ffilter,2,true)
	-- 注册接触融合召唤规则：从我方手牌·场上·墓地的上述素材返回卡组/额外卡组的场合才能从额外卡组特殊召唤（不需要融合）
	aux.AddContactFusionProcedure(c,s.cfilter,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,aux.ContactFusionSendToDeck(c))
	-- 必须将上述卡从自己的手卡·场上·墓地返回卡组·额外卡组的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：自己的卡通怪兽可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置直接攻击效果的对象为所有卡通怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TOON))
	c:RegisterEffect(e2)
	-- ②：1回合1次，在自己的主要阶段可以发动。从自己的墓地将1张“卡通”卡或记述有“卡通”卡名的卡加入手牌。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ③：自己的卡通怪兽被攻击的伤害计算时可以发动。将那只怪兽除外直到伤害步骤结束时。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.rmcon)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
end
-- 定义接触融合素材过滤函数，用于判断卡片是否为「卡通青眼白龙」或怪兽卡，且可以返回卡组或额外卡组
function s.cfilter(c)
	return (c:IsFusionCode(53183600) or c:IsType(TYPE_MONSTER))
		and c:IsAbleToDeckOrExtraAsCost()
end
-- 定义融合素材过滤函数，用于筛选卡通怪兽
function s.ffilter(c)
	return c:IsType(TYPE_TOON)
end
-- 定义过滤函数，筛选我方墓地中的「卡通」卡、记述有「卡通」系列或「卡通世界」的卡片
function s.thfilter(c)
	-- 判断卡片是否属于「卡通」系列，或记载有「卡通」系列或「卡通世界」
	return (c:IsSetCard(0x62) or aux.IsSetNameMonsterListed(c,0x62) or aux.IsCodeListed(c,15259703))
		and c:IsAbleToHand()
end
-- 定义回收墓地卡片效果（效果②）的发动准备与检查函数（Target）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方墓地中是否存在符合回收条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置将1张卡从墓地回收至手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 定义回收墓地卡片效果（效果②）的实际执行逻辑函数（Operation）
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家提示：选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家在墓地选择1张符合回收条件的卡（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选定的卡通卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 展示加入手牌的卡给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义避免战斗破坏的临时除外效果（效果③）的发动条件判断函数
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 定义临时除外效果（效果③）的发动准备与检查函数（Target）
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	e:SetLabelObject(d)
	return a:IsControler(1-tp) and d and d:IsType(TYPE_TOON) and d:IsControler(tp)
end
-- 获取攻击宣言的发动怪兽（攻击者）
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():IsAbleToRemove() end
	-- 将正准备被攻击的我方卡通怪兽注册为当前连锁的目标对象
	Duel.SetTargetCard(e:GetLabelObject())
	-- 设置将该被攻击的卡通怪兽除外的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
-- 定义临时除外效果（效果③）的实际执行逻辑函数（Operation）
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsRelateToChain() then
		-- 尝试将被攻击的怪兽暂时除外，并判断是否除外成功
		if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			-- 直到伤害步骤结束时。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_DAMAGE_STEP_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(tc)
			e1:SetCountLimit(1)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			-- 注册延迟执行将怪兽带回场上的全局事件监听效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 定义返回场上效果的发动条件函数，检查怪兽是否带有除外的标记
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
-- 定义返回场上效果的执行函数
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将被临时除外的卡通怪兽送回场上
	Duel.ReturnToField(e:GetLabelObject())
end
