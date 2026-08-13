--スプリガンズ・メリーメイカー
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从额外卡组特殊召唤的场合才能发动。从卡组把1只「护宝炮妖」怪兽送去墓地。
-- ②：对方的主要阶段以及战斗阶段才能发动。这张卡直到结束阶段除外。把持有超量素材2个以上的这张卡除外的场合，可以再从额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽送去墓地。
local s,id,o=GetID()
-- 初始化效果：为「护宝炮妖欢乐制造机」注册以「阿不思的落胤」为素材的记载、4星怪兽×2的XYZ召唤手续与苏生限制，并定义①特殊召唤成功时从卡组将1只「护宝炮妖」怪兽送去墓地、②对方主要阶段/战斗阶段将自身暂时除外并可选追加送墓融合怪兽的两个效果。
function c48285768.initial_effect(c)
	-- 记录这张卡在文本中记载了卡名「阿不思的落胤」（卡号68468459），用于实现融合素材相关的检索与判定。
	aux.AddCodeList(c,68468459)
	-- 为这张卡添加XYZ召唤手续：以2只4星怪兽为超量素材进行XYZ召唤（不限制素材种族/属性）。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡从额外卡组特殊召唤的场合才能发动。从卡组把1只「护宝炮妖」怪兽送去墓地。
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
	-- ②：对方的主要阶段以及战斗阶段才能发动。这张卡直到结束阶段除外。把持有超量素材2个以上的这张卡除外的场合，可以再从额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽送去墓地。
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
-- 效果①的发动条件：仅在自身从额外卡组特殊召唤成功的场合才能发动（IsSummonLocation(LOCATION_EXTRA)判定）。
function c48285768.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 定义①效果可选的卡：必须是怪兽卡、属于「护宝炮妖」字段（SetCard 0x155）、且能够被送去墓地。
function c48285768.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x155) and c:IsAbleToGrave()
end
-- 效果①的发动时点判定：检查卡组中是否存在符合条件的「护宝炮妖」怪兽（chk==0），并设置处理时从卡组将1张卡送去墓地的操作信息。
function c48285768.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0（发动时合法性检查）时，确认自己卡组里至少有1只满足tgfilter的「护宝炮妖」怪兽，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c48285768.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：效果处理时将从自己卡组把1张卡送去墓地（CATEGORY_TOGRAVE，对象未确定，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的结算：玩家从卡组选择1只「护宝炮妖」怪兽，选择后将其以效果原因送去墓地。
function c48285768.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择提示框，提示文字为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己卡组中筛选并选择1只满足tgfilter的「护宝炮妖」怪兽。
	local g=Duel.SelectMatchingCard(tp,c48285768.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将上一步选择的怪兽以效果原因（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果②的发动条件：当前是对方回合，且时点位于对方主要阶段1、战斗阶段（开始阶段至战斗阶段结束）或主要阶段2，此时这张卡在场上才能发动。
function c48285768.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段并存入ph变量，用于后续判定是否处于对方的主要阶段/战斗阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判定是否满足②发动条件：对方回合并且当前阶段是主要阶段1、战斗阶段（含开始和结束）或主要阶段2。
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end
-- 效果②的发动条件检查：自身必须能够被除外（IsAbleToRemove），并设置将这张卡从场上除外的操作信息。
function c48285768.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 设置操作信息：本次处理会将效果持有者（即这张卡）以除外形式处理（CATEGORY_REMOVE，对象确定为自身，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 定义追加送墓可选对象的过滤条件：从额外卡组选出的卡必须是融合怪兽，且其融合素材中记载有「阿不思的落胤」（卡号68468459）。
function c48285768.exfilter(c)
	-- 判断卡片是否同时满足：为融合怪兽类型、且卡面素材包含「阿不思的落胤」，以此筛选可送去墓地的融合怪兽。
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459)
end
-- 效果②的结算：将自身暂时除外并在结束阶段返回；若除外前持有2个以上超量素材，则追加可选处理，从额外卡组将1只以「阿不思的落胤」为素材的融合怪兽送去墓地。
function c48285768.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local ct=c:GetOverlayCount()
		-- 执行将自身以效果原因且附带REASON_TEMPORARY（暂时除外）的方式除外；只有除外交际成功且卡的原始卡号仍为本卡时，才注册结束阶段回归效果。
		if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
			-- ②：这张卡直到结束阶段除外。把持有超量素材2个以上的这张卡除外的场合，可以再从额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽送去墓地。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(c)
			e1:SetCountLimit(1)
			e1:SetOperation(c48285768.retop)
			-- 将刚创建的连续效果注册到场上（EFFECT_TYPE_FIELD），使其在结束阶段执行retop，把暂时除外的这张卡返回场上。
			Duel.RegisterEffect(e1,tp)
		end
		-- 判断除外前这张卡持有的超量素材数量是否≥2，且额外卡组存在满足exfilter的融合怪兽，若都满足则可进入追加送墓分支。
		if ct>=2 and Duel.IsExistingMatchingCard(c48285768.exfilter,tp,LOCATION_EXTRA,0,1,nil)
			-- 弹出是否发动追加效果的选择框，提示文字为“是否再把融合怪兽送去墓地？”；玩家选择“是”才继续执行后续送墓。
			and Duel.SelectYesNo(tp,aux.Stringid(48285768,2)) then  --"是否再把融合怪兽送去墓地？"
			-- 调用Duel.BreakEffect中断当前效果处理，使后续的追加送墓在时点上与前一步的除外处理分开，防止错过时点。
			Duel.BreakEffect()
			-- 显示选择提示框，提示文字为“请选择要送去墓地的卡”，为选择额外卡组的融合怪兽做准备。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 让玩家从额外卡组中选择1只满足exfilter的融合怪兽（以「阿不思的落胤」为融合素材的融合怪兽）。
			local g=Duel.SelectMatchingCard(tp,c48285768.exfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选择的融合怪兽以效果原因送去墓地。
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end
-- 结束阶段处理函数：将被暂时除外的这张卡返回场上，实现“直到结束阶段除外”的回归。
function c48285768.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将标签对象（即被暂时除外的这张卡）返回场上，返回时使用离场前的表示形式，完成结束阶段回归。
	Duel.ReturnToField(e:GetLabelObject())
end
