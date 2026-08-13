--Recette de Personnel～賄いのレシピ～
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只仪式怪兽为对象才能发动。在自己场上把1只「新式魔厨衍生物」（恶魔族·暗·1星·攻/守50）特殊召唤。这衍生物的等级变成和作为对象的怪兽相同。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放，从手卡把1只「新式魔厨」仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 初始化效果注册函数：创建并注册“允许发动”的空白效果（使魔陷能发动），然后创建并注册①效果（以自己场上仪式怪兽为对象，特殊召唤「新式魔厨衍生物」并变更其等级，1回合1次），最后通过公共仪式辅助函数生成并注册②效果（以自身送墓为代价从手卡进行「新式魔厨」仪式召唤，1回合1次）。
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
	-- 调用公共辅助函数为这张卡添加仪式召唤效果：从手卡选择满足s.filter（「新式魔厨」字段）的仪式怪兽，解放的手卡·场上怪兽等级合计必须等于该仪式怪兽的等级。
	local e3=aux.AddRitualProcEqual2(c,s.filter,LOCATION_HAND,nil,nil,true)
	e3:SetDescription(aux.Stringid(id,1))  --"仪式召唤"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.ritcost)
	c:RegisterEffect(e3)
end
-- 判断怪兽是否为自己场上表侧表示且为仪式怪兽（0x81表示同时具备怪兽类型与仪式类型）。
function s.tgfilter(c)
	return c:IsFaceup() and c:GetType()&0x81==0x81
end
-- ①效果的发动条件判定与取对象逻辑：检查自己怪兽区是否有空格、是否存在满足条件的表侧仪式怪兽、以及玩家能否特殊召唤该衍生物；若为对象合法性检查，则确认候选卡位于自己怪兽区、控制者是自己且满足筛选条件。
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	-- 发动条件之一：自己主要怪兽区域存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之一：自己场上存在至少1只符合条件的表侧仪式怪兽可作为对象。
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 发动条件之一：玩家当前能够特殊召唤「新式魔厨衍生物」（恶魔族·暗·1星·攻/守50）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,40551411,0,TYPES_TOKEN_MONSTER,50,50,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP) end
	-- 向操作者显示“请选择表侧表示的卡”的界面提示，用于选择对象的UI消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作者从自己场上表侧表示的仪式怪兽中选择1张，并将其登记为当前连锁的对象（取对象效果）。
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向系统登记本次连锁将生成1只衍生物的操作信息，供其他卡的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 向系统登记本次连锁将进行1只怪兽的特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ①效果处理函数：先检查自己怪兽区仍有空格、且玩家仍可特殊召唤该衍生物；若条件不满足则终止处理，否则继续生成并特殊召唤衍生物、根据对象等级修改衍生物等级，最后完成特殊召唤。
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有空位，则本次效果处理不成功。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 若玩家当前不能特殊召唤「新式魔厨衍生物」，则直接终止处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,40551411,0,TYPES_TOKEN_MONSTER,50,50,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP) then return end
	-- 在自己场上创建一只「新式魔厨衍生物」（卡号40551411）的衍生物实体。
	local token=Duel.CreateToken(tp,40551411)
	-- 以表侧表示将衍生物特殊召唤到自己怪兽区（作为多步特殊召唤的第一步）；若成功则继续为其赋予等级变更效果，最后调用SpecialSummonComplete完成整个特殊召唤流程。
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		-- 取回发动时选择的对象怪兽（作为对象的仪式怪兽）。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			local lv=tc:GetLevel()
			-- 这衍生物的等级变成和作为对象的怪兽相同。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1)
		end
		-- 完成多步特殊召唤的收尾处理，并触发特殊召唤成功时点。
		Duel.SpecialSummonComplete()
	end
end
-- 判断怪兽是否属于「新式魔厨」系列（字段0x196），用于筛选可仪式召唤的对象。
function s.filter(c,e,tp)
	return c:IsSetCard(0x196)
end
-- ②效果的代价判定与支付：确认这张卡可送去墓地且处于表侧表示效果有效状态，实际支付时将魔法与陷阱区域的这张表侧表示卡送去墓地。
function s.ritcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 将这张卡以“代价”的原因从魔法与陷阱区域送去墓地。
	Duel.SendtoGrave(c,REASON_COST)
end
