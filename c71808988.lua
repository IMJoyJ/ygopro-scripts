--ブルーアイズ・トゥーン・アルティメットドラゴン
local s,id,o=GetID()
-- 初始化效果，启用复活限制并注册融合召唤和接触融合手续，设置特殊召唤条件、直接攻击效果以及两个发动效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加融合素材必须包含编号53183600的卡片
	aux.AddMaterialCodeList(c,53183600)
	-- 为该卡注册系列字段0x62（蓝眼系列）以支持相关判定
	aux.AddSetNameMonsterList(c,0x62)
	-- 设置该卡的融合召唤手续：使用一张融合代码为53183600的怪兽和两张满足s.ffilter条件的怪兽作为素材进行融合召唤
	aux.AddFusionProcFunFun(c,aux.FilterBoolFunction(Card.IsFusionCode,53183600),s.ffilter,2,true)
	-- 注册接触融合程序，允许从手牌、怪兽区或墓地选择符合条件的卡片作为融合素材并送回卡组作为代价
	aux.AddContactFusionProcedure(c,s.cfilter,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,aux.ContactFusionSendToDeck(c))
	-- 设置该卡不能被无效且不能复制的特殊召唤条件效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 设置该卡获得直接攻击效果，仅对场上的蓝眼系列怪兽生效
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设定直接攻击效果的目标为所有场上的蓝眼系列怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TOON))
	c:RegisterEffect(e2)
	-- 设置该卡的第1个发动效果：从墓地将符合条件的卡加入手牌
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- 设置该卡的第2个发动效果：在伤害计算前，若对方蓝眼系列怪兽攻击己方怪兽，则将其除外并于回合结束时返回场上
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
-- 定义接触融合使用的过滤条件：卡片必须是融合代码为53183600或类型为怪兽，并且可以送回卡组或额外卡组作为代价
function s.cfilter(c)
	return (c:IsFusionCode(53183600) or c:IsType(TYPE_MONSTER))
		and c:IsAbleToDeckOrExtraAsCost()
end
-- 定义融合召唤中作为素材的过滤条件：卡片必须是TOON类型
function s.ffilter(c)
	return c:IsType(TYPE_TOON)
end
-- 定义从墓地检索加入手牌的卡片过滤条件：必须属于蓝眼系列、记述了蓝眼系列怪兽或包含特定卡号15259703
function s.thfilter(c)
	-- 判断卡片是否属于蓝眼系列、记述了蓝眼系列怪兽或包含特定卡号15259703
	return (c:IsSetCard(0x62) or aux.IsSetNameMonsterListed(c,0x62) or aux.IsCodeListed(c,15259703))
		and c:IsAbleToHand()
end
-- 设置第1个发动效果的检索条件：检查己方墓地是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足第1个发动效果的检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置第1个发动效果的操作信息，指定将要处理的卡为墓地中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 设置第1个发动效果的操作函数，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方墓地中选择满足条件的1张卡作为目标
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对手看到被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 设置第2个发动效果的触发条件：攻击方为对方，被攻击方为己方蓝眼系列怪兽
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中攻击方的卡
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	e:SetLabelObject(d)
	return a:IsControler(1-tp) and d and d:IsType(TYPE_TOON) and d:IsControler(tp)
end
-- 设置第2个发动效果的目标函数，检查目标是否可以被除外
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():IsAbleToRemove() end
	-- 将目标卡设为处理对象
	Duel.SetTargetCard(e:GetLabelObject())
	-- 设置第2个发动效果的操作信息，指定将要处理的卡为被攻击的蓝眼系列怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
-- 设置第2个发动效果的操作函数，将目标怪兽除外并注册返回场上的效果
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsRelateToChain() then
		-- 将目标怪兽以REASON_EFFECT+REASON_TEMPORARY原因除外
		if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			-- 注册一个在伤害步骤结束时触发的效果，用于将被除外的卡返回场上
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_DAMAGE_STEP_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(tc)
			e1:SetCountLimit(1)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			-- 将该效果注册到游戏环境
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 判断是否满足返回场上的条件：目标卡是否有指定标志位
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
-- 执行返回场上的操作，将目标卡返回场上
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标卡返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
