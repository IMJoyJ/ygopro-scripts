--スプリガンズ・メリーメイカー
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从额外卡组特殊召唤的场合才能发动。从卡组把1只「护宝炮妖」怪兽送去墓地。
-- ②：对方的主要阶段以及战斗阶段才能发动。这张卡直到结束阶段除外。把持有超量素材2个以上的这张卡除外的场合，可以再从额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽送去墓地。
local s,id,o=GetID()
-- 初始化效果，注册两个效果，分别为①和②的效果
function c48285768.initial_effect(c)
	-- 记录该卡拥有「阿不思的落胤」这张卡名
	aux.AddCodeList(c,68468459)
	-- 添加XYZ召唤手续，需要4星怪兽叠放2只
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 效果①：从额外卡组特殊召唤成功时发动，将1只护宝炮妖怪兽送去墓地
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48285768,0))  --"从卡组把1只「护宝炮妖」怪兽送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,48285768)
	e1:SetCondition(c48285768.tgcon)
	e1:SetTarget(c48285768.tgtg)
	e1:SetOperation(c48285768.tgop)
	c:RegisterEffect(e1)
	-- 效果②：对方的主要阶段或战斗阶段才能发动，将自己除外并可再从额外卡组送融合怪兽到墓地
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48285768,1))  --"这张卡直到结束阶段除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCountLimit(1,48285768)
	e2:SetCondition(c48285768.rmcon)
	e2:SetTarget(c48285768.rmtg)
	e2:SetOperation(c48285768.rmop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：该卡从额外卡组特殊召唤成功
function c48285768.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤函数，用于筛选护宝炮妖怪兽
function c48285768.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x155) and c:IsAbleToGrave()
end
-- 效果①的目标设定，检查是否有护宝炮妖怪兽在卡组中
function c48285768.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有护宝炮妖怪兽在卡组中
	if chk==0 then return Duel.IsExistingMatchingCard(c48285768.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将1只护宝炮妖怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理，选择并送去墓地
function c48285768.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的护宝炮妖怪兽
	local g=Duel.SelectMatchingCard(tp,c48285768.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果②的发动条件：对方回合且在主要阶段或战斗阶段
function c48285768.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断是否为对方回合且处于主要阶段或战斗阶段
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end
-- 效果②的目标设定，检查该卡能否除外
function c48285768.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 设置操作信息为将该卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 过滤函数，用于筛选以阿不思的落胤为融合素材的融合怪兽
function c48285768.exfilter(c)
	-- 判断是否为融合怪兽且以阿不思的落胤为融合素材
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459)
end
-- 效果②的处理，将自己除外并可再送融合怪兽到墓地
function c48285768.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local ct=c:GetOverlayCount()
		-- 将该卡以临时除外方式移除
		if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
			-- 注册一个在结束阶段返回场上的效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(c)
			e1:SetCountLimit(1)
			e1:SetOperation(c48285768.retop)
			-- 注册效果e1给玩家tp
			Duel.RegisterEffect(e1,tp)
		end
		-- 检查是否有超量素材2个以上且额外卡组有融合怪兽可送墓
		if ct>=2 and Duel.IsExistingMatchingCard(c48285768.exfilter,tp,LOCATION_EXTRA,0,1,nil)
			-- 询问玩家是否再送融合怪兽到墓地
			and Duel.SelectYesNo(tp,aux.Stringid(48285768,2)) then  --"是否再把融合怪兽送去墓地？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 选择满足条件的融合怪兽
			local g=Duel.SelectMatchingCard(tp,c48285768.exfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选中的融合怪兽送去墓地
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end
-- 返回场上的处理函数
function c48285768.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该卡返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
