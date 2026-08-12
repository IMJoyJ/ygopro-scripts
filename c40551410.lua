--Recette de Personnel～賄いのレシピ～
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只仪式怪兽为对象才能发动。在自己场上把1只「新式魔厨衍生物」（恶魔族·暗·1星·攻/守50）特殊召唤。这衍生物的等级变成和作为对象的怪兽相同。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放，从手卡把1只「新式魔厨」仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册发动、特殊召唤和仪式召唤相关效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只仪式怪兽为对象才能发动。在自己场上把1只「新式魔厨衍生物」（恶魔族·暗·1星·攻/守50）特殊召唤。这衍生物的等级变成和作为对象的怪兽相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤衍生物"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
	-- 为卡片添加仪式召唤效果，要求素材等级总和等于仪式怪兽等级
	local e3=aux.AddRitualProcEqual2(c,s.filter,LOCATION_HAND,nil,nil,true)
	e3:SetDescription(aux.Stringid(id,1))  --"仪式召唤"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.ritcost)
	c:RegisterEffect(e3)
end
-- 判断目标怪兽是否为表侧表示的仪式怪兽
function s.tgfilter(c)
	return c:IsFaceup() and c:GetType()&0x81==0x81
end
-- 设置特殊召唤衍生物效果的目标选择和条件检查
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家场上是否存在符合条件的仪式怪兽作为目标
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,40551411,0,TYPES_TOKEN_MONSTER,50,50,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP) end
	-- 提示玩家选择表侧表示的怪兽作为目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置效果操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 执行特殊召唤衍生物效果的处理函数
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查玩家是否可以特殊召唤指定的衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,40551411,0,TYPES_TOKEN_MONSTER,50,50,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP) then return end
	-- 创建指定编号的衍生物卡片
	local token=Duel.CreateToken(tp,40551411)
	-- 尝试特殊召唤创建的衍生物
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		-- 获取当前效果的目标怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			local lv=tc:GetLevel()
			-- 将目标怪兽的等级赋予衍生物
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1)
		end
		-- 完成特殊召唤操作
		Duel.SpecialSummonComplete()
	end
end
-- 判断卡片是否为「新式魔厨」系列
function s.filter(c,e,tp)
	return c:IsSetCard(0x196)
end
-- 设置仪式召唤效果的费用支付函数
function s.ritcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 将此卡送去墓地作为仪式召唤的费用
	Duel.SendtoGrave(c,REASON_COST)
end
